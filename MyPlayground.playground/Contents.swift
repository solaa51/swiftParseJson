//: Playground - noun: a place where people can play

import UIKit

/**
 * 一个具体的值
 * 因为json中具体值的类型可能为 字符串/整数/小数
 */
struct JsonValue{
    let string: String?
    let int: Int?
    let double: Double?
    init(){
        self.string = nil
        self.int    = nil
        self.double = nil
    }
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

extension String {
    //分割字符串
    func explode(分隔符 delimiter: String) -> [String]{
        return self.componentsSeparatedByString(delimiter)
    }
    
    //去除左右空格和换行符
    func trim() -> String{
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    //字符串替换
    func replace(target: String, withString: String) -> String{
        return self.stringByReplacingOccurrencesOfString(target, withString: withString)
    }
}



/*******示例*******/
//{"ret":0,"data":{"list":[{"id":1,"name":"\u6e38\u620f"},{"id":2,"name":"\u8d44\u8baf"}],"count":30}}
//,\"data\":{\"list\":[{\"id\":1,\"name\":\"\\u6e38\\u620f\"},{\"id\":2,\"name\":\"\\u8d44\\u8baf\"}]
let 类型数据 = "{\"ret\":0,\"count\":30,\"name\":\"lisuliang\"}"

func parseJson(str: String) -> Dictionary<String,JsonNode> {
    var tempJsonData = str
    if 类型数据.hasPrefix("{"){
        //去除第一个字符 和 最后一个字符
        tempJsonData = tempJsonData.substringWithRange(Range(tempJsonData.startIndex.advancedBy(1)..<tempJsonData.endIndex.advancedBy(-1)))
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

var 解析成字典 = Dictionary<String,JsonNode>()
parseJson(类型数据)


for (key,val) in 解析成字典{
    if let a=val.val!.int {
        print("\(key) 整数值为 \(a)")
        continue
    }
    
    if let a=val.val!.string {
        print("\(key) 字符串值为 \(a)")
        continue
    }
}

解析成字典["name"]?.val?.string










/*********示例end***********/






let 构建个数据: Dictionary = ["a":"b", "age":"18"]

let arr = [[1],[2,3]]


//json数据值结构体


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




