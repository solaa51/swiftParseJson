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
    
    func subChar(i:Int) -> Character{
        if i<0{
            return self[self.endIndex.advancedBy(i)]
        }else{
            return self[self.startIndex.advancedBy(i)]
        }
    }
    
    func substr(s: Int, e: Int) -> String{
        return self.substringWithRange(Range(self.startIndex.advancedBy(s)...self.startIndex.advancedBy(e)))
    }
    
    //替换字符串
    mutating func strReplace(s: Int, e: Int, withStr: String){
        return self.replaceRange(Range(self.startIndex.advancedBy(s)...self.startIndex.advancedBy(e)), with: withStr)
    }
    
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
    
    //去除第一个字符和最后一个字符
    func clearHeadAndTail() -> String{
        return self.substringWithRange( Range(self.startIndex.advancedBy(1)..<self.endIndex.advancedBy(-1)) )
    }
}



/*******示例*******/
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

data["data"]?.val?.string

/*********示例end***********/

