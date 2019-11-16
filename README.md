# flutter_iconv
利用ffi调用iconv转换编码
a demo use ffi iconv ffi调用iconv
only support android 只有安卓
## Getting Started
#### gbk to utf8 string
```

Future<String> _get4399()async{
  var rep=await http.get("http://www.4399.com");
  var byte=await iconv(rep.bodyBytes,formcode: "gbk",tocode: "utf-8");
  return await utf8.decode(byte);
}
```

