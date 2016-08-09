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

### 今日先到此  明日继续完善