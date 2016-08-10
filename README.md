## 刚学swift想搞点花出来，自己搞个json解析的  纯属练手
# 查看了网上的一些解析，发现都使用了NS的库函数，于是想不依靠NS库，纯swift写个解析
# 我本人是PHP出身 思想上有些地方一时没转过弯
# 有些概念还没搞清，不过懒得计较了
起初先做了一些尝试 
	 struct JsonValue{
	    let string: String?
	    let int: Int?
	    let double: Double?
	    init(string: String){
	        self.string = string
	        self.int    = nil
	        self.double = nil
	    }
	
	    init(int: Int?){
	        self.string = nil
	        self.int    = int
	        self.double = nil
	    }
	}
	var jsonStr = "{\"a\":\"b\", \"c\":\"d\"}";
	//jsonStr.characters.count
	var 解析后JSON = Dictionary<String,JsonValue>()
	if jsonStr.hasPrefix("{"){
	    //去除最外层的 {}
	    jsonStr = jsonStr.substringWithRange( Range(jsonStr.startIndex.advancedBy(1) ..< jsonStr.endIndex.advancedBy(-1)) )
	
	    let arr = jsonStr.componentsSeparatedByString(",")
	    for item in arr{
	        let 去除空格换行 = item.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
	        let 替换双引号 = 去除空格换行.stringByReplacingOccurrencesOfString("\"", withString: "")
	
	        let 拆分键值对 = 替换双引号.componentsSeparatedByString(":")
	        let key = 拆分键值对[0]
	        let val = 拆分键值对[1]
	        解析后JSON[key] = JsonValue(string: val)
	    }
	}
	解析后JSON["a"]?.string
	解析后JSON["c"]?.string
	struct JsonKeyValue{
	    let key: String
	    let val: JsonValue
	}
	
	var 整形数json = "[1,2,3,\"a\":\"b\"]"
	var 解析后整形 = Dictionary<String,JsonValue>()
	
	//解析键值对
	func parseKeyValue(str:String) -> Dictionary<String,JsonValue>
	{
	    var ret = Dictionary<String,JsonValue>()
	
	    let 去除空格换行 = str.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
	    let 替换双引号 = 去除空格换行.stringByReplacingOccurrencesOfString("\"", withString: "")
	
	    let 拆分键值对 = 替换双引号.componentsSeparatedByString(":")
	    let key = 拆分键值对[0]
	    let val = 拆分键值对[1]
	    ret[key] = JsonValue(string: val)
	
	    return ret
	}
	
	//解析json中的数组
	func parseArray(json:String) -> Dictionary<String,JsonValue>
	{
	    var 解析后整形1 = Dictionary<String,JsonValue>()
	    //去除[]
	    let 去除中括号 = 整形数json.substringWithRange( Range(整形数json.startIndex.advancedBy(1)..<整形数json.endIndex.advancedBy(-1)) )
	
	    //用逗号分隔成数组
	    let 数组 = 去除中括号.componentsSeparatedByString(",")
	
	    for (key,item) in 数组.enumerate(){
	        //判断是否为对象形式
	        if item.localizedStandardContainsString(":") {
	            let temp = parseKeyValue(item)
	            解析后整形1[temp.keys.first!] = temp.values.first
	        }else{
	            let strKey = "\(key)" //key值转为字符串
	            解析后整形1[strKey] = JsonValue(int: Int(item))   //字符串转为整形
	        }
	    }
	    return 解析后整形1
	}
	解析后整形 = parseArray(整形数json)
	解析后整形["a"]?.string

## 思索再三后 制定了一下结构
	/**
	 * 一个具体的值
	 * 因为json中具体值的类型可能为 字符串/整数/小数
	 */
	struct JsonValue{
	    let string: String?
	    let int: Int?
	    let double: Double?
	
	    init(string: String){
	        self.string = string
	        self.int    = nil
	        self.double = nil
	    }
	
	    init(int: Int?){
	        self.string = nil
	        self.int    = int
	        self.double = nil
	    }
	
	    init(double: Double?){
	        self.string = nil
	        self.int    = nil
	        self.double = double
	    }
	}
	
	/**
	 * 一个节点的结构
	 * 每一个键值对就看成是一个节点
	 * 有可能是一个具体的值 也 有可能包含了子节点
	 */
	struct JsonNode{
	    let key: String
	    let val: JsonValue?
	    let node: Dictionary<String, JsonNode>?
	
	    init(key: String, val: JsonValue){
	        self.key = key
	        self.val = val
	        self.node = nil
	    }
	
	    init(key: String, node: Dictionary<String, JsonNode>){
	        self.key = key
	        self.val = nil
	        self.node = node
	    }
	}
	
	var data = Dictionary<String, JsonNode>()
	
	//状态值
	let 状态 = JsonNode( key: "ret", val: JsonValue(int: 0) )
	data["ret"] = 状态
	//data["ret"]?.val?.int
	
	var 数据集 = Dictionary<String, JsonNode>()
	var 年龄 = JsonNode( key: "age", val: JsonValue(int: 28) )
	数据集["age"] = 年龄
	
	data["data"] = JsonNode( key:"data", node:数据集 )
	data["data"]?.node!["age"]?.val?.int

# 今日先到此  明日继续完善

### 晚上想了又想发现结构不对
一个json对象包含很多对 键值，每个键的值又可以看成是一个节点
	/**
	 * 一个节点的值结构
	 * 每一个键值对就看成是一个节点
	 * 有可能是一个具体的值 也 有可能包含了子节点
	 */
	struct JsonNode{
	    let val: JsonValue?
	    let node: Dictionary<String, JsonNode>?
	    init(val: JsonValue){
	        self.val = val
	        self.node = nil
	    }
	    init(node: Dictionary<String, JsonNode>){
	        self.val = nil
	        self.node = node
	    }
	}

如果一个json对象是个一维的很容易就能解决
1. 按,分割成一个个的节点
2. 遍历节点
3. 检查有没有; 
4. 有分号用;把节点分割为键和值，没有用递增值补上再转为字符串
5. 对值类型做判断，有”则为字符串 过滤掉”后存储 有小数点为浮点数  其他为整数
## 因为本人是PHP出身 
## 这他妈的函数太长了 日 看起来真他妈累
## 于是扩展了下String结构方法 函数名趋近与PHP
	func parseJson(str: String) -> Dictionary<String,JsonNode> {
	    var 解析成字典 = Dictionary<String,JsonNode>()
	    var tempJsonData = str
	    if 类型数据.hasPrefix("{"){
	        //去除第一个字符 和 最后一个字符
	        tempJsonData = tempJsonData.clearHeadAndTail()
	    }
	    
	    //按,分割成数组  一个个键值对
	    let 数组键值对 = tempJsonData.explode(分隔符:",")
	    for 键值对 in 数组键值对{
	        //去除空格换行符
	        let 去除空格换行 = 键值对.trim()
	        //按冒号分割
	        var 键值分离 = 去除空格换行.explode(分隔符: ":")
	        //判断val是否有" 以及小数点 确定数据类型
	        var val = JsonValue()
	        if (键值分离[1].rangeOfString("\"") != nil){ //字符串值类型
	            键值分离[1] = 键值分离[1].replace("\"", withString: "")
	            val = JsonValue(string: 键值分离[1])
	        }else if( 键值分离[1].rangeOfString(".") != nil ){ //小数类型
	            val = JsonValue(double: Double(键值分离[1]))
	        }else{ //整数类型
	            val = JsonValue(int: Int(键值分离[1])) //Int(键值分离[1]) 字符串转int
	        }
	        键值分离[0] = 键值分离[0].replace("\"", withString: "")
	        解析成字典[键值分离[0]] = JsonNode(val: val)
	    }
	    return 解析成字典
	}

## 以上只是简单的类型 但是这个肯定不现实
一个json对象有很多节点，每个节点既可以是值，也可以是一个节点
json字符串中每个节点下都可能再包含, : {}  []这些分割用的符号
简单分割可定是不行了

所以只能分析字符串结构 {}是一个对象  []包含一个数组  其中也可能再包含
如果能把复杂的类型 转为简单的类型，那些就可以解析简单类型
json中无外乎有两种特殊对{}  []
那么我依次替换掉外层的符号对 用特殊符号替换段内容
等转换出来后再替换回去，然后在一层层去解析  
目前只实现了一层
	var 类型数据 = "{\"ret\":0,\"data\":{\"name\":\"lisulaing\",\"score\":{\"yuwen\":100,\"yingyu\":100}},\"level\":[1,8,9]}"
	
	//逐字符遍历查找次级的{} 和 [] 分别用特定字符替换
	类型数据 = 类型数据.clearHeadAndTail()
	
	var subStrArray1 = [String]() //存放替换掉得字符串
	var subStrArray2 = [String]() //存放替换掉得字符串
	func repeatLevel(inout str: String, i:Int, type:Int=1){
	    let left:Character
	    let right:Character
	    if type==1{
	        left = "{"; right = "}"
	    }else{
	        left = "["; right = "]"
	    }
	    var j=0,ikeyStart=0,ikeyEnd=0
	    for (k,v) in str.characters.enumerate(){
	        if v==left {
	            j+=1
	            if ikeyStart==0 {
	                ikeyStart = k
	            }
	        }
	        if v==right {
	            j-=1
	            if j==0 {
	                ikeyEnd = k
	                if type==1{
	                    subStrArray1.append(str.substr(ikeyStart, e: ikeyEnd))
	                    str.strReplace(ikeyStart, e: ikeyEnd, withStr: "\"#\(i)#\"")
	                }else{
	                    subStrArray2.append(str.substr(ikeyStart, e: ikeyEnd))
	                    str.strReplace(ikeyStart, e: ikeyEnd, withStr: "\"@\(i)@\"")
	                }
	                
	                repeatLevel(&str, i: i+1, type: type)
	                break;
	            }
	        }
	    }
	}
	repeatLevel(&类型数据, i: 0, type: 1)
	repeatLevel(&类型数据, i: 0, type: 2)

	let data = parseJson(类型数据)
	for (key,val) in data{
	    if let a=val.val!.int {
	        print("\(key) 整数值为 \(a)")
	        continue
	    }
	    
	    if let a=val.val!.string {
	        print("\(key) 字符串值为 \(a)")
	        continue
	    }
	}
