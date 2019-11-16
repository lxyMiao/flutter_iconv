import 'dart:ffi' as ffi;
import 'dart:ffi' show Pointer ,Int64,Uint8;
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
typedef _i_open_native=ffi.Pointer<ffi.Void> Function(ffi.Pointer<Utf8>,ffi.Pointer<Utf8>);
typedef _i_iconv_native=ffi.Int64 Function(
    ffi.Pointer<ffi.Void>,
    ffi.Pointer<ffi.Uint8>,ffi.Pointer<ffi.Int64>,
    ffi.Pointer<ffi.Uint8>,ffi.Pointer<ffi.Int64>
    );
typedef _i_close_native=ffi.IntPtr Function(ffi.Pointer<ffi.Void>);
typedef _i_iconv=int Function(
    ffi.Pointer<ffi.Void>,
    ffi.Pointer<ffi.Uint8>,ffi.Pointer<ffi.Int64>,
    ffi.Pointer<ffi.Uint8>,ffi.Pointer<ffi.Int64>
    );
typedef _i_close=int Function(ffi.Pointer<ffi.Void>);
final _lib=ffi.DynamicLibrary.open("libiconvd.so");
final _open=_lib.lookupFunction<_i_open_native,_i_open_native>("iconvd_open");
final _iconv=_lib.lookupFunction<_i_iconv_native,_i_iconv>("iconvd");
final _close=_lib.lookupFunction<_i_close_native,_i_close>("iconvd_close");
ffi.Pointer<T> allocate<T extends ffi.NativeType>({int count = 1}){
  final int  totalSize=count*ffi.sizeOf<T>();
  ffi.Pointer<T> result;
  result=ffi.Pointer.allocate(count: totalSize);
  if(result.address==0){
    throw ArgumentError("Could allocate $totalSize bytes");
  }
  return result;
}

Future<Uint8List> iconv(Uint8List inb,{String tocode ="utf-8", String fromcode ="gbk"})async{
  if(inb==null)
    throw ArgumentError.notNull("bytes is null");
  if(tocode==null)
    throw ArgumentError.notNull("tocode is null");
  if(fromcode==null)
    throw ArgumentError.notNull("fromcode is null");

  final _tp=_open(Utf8.toUtf8(tocode),Utf8.toUtf8(fromcode));
  if(_tp.address==0)
    throw Exception("open iconv failed");
  final ilenp=allocate<ffi.Int64>();
  final olenp=allocate<ffi.Int64>();
  int outleng=inb.length*2+1;
  ilenp.store(inb.length+1);
  olenp.store(outleng);
  final ffi.Pointer<ffi.Uint8> ipointer=allocate<ffi.Uint8>(count: inb.length+1);
  final opinter=allocate<ffi.Uint8>(count: outleng);
  for(var i=0;i<inb.length;i++){
    ipointer.elementAt(i).store(inb[i]);
  }
  ipointer.elementAt(inb.length).store(0);
  _iconv(_tp,ipointer,ilenp,opinter,olenp);
  _close(_tp);
  ipointer.free();
  return opinter.asExternalTypedData(count: outleng).buffer.asUint8List();
}