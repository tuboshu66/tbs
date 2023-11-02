var fs=require('fs')
console.log('程序开始运行');
fs.readFile('/usr/local/nginx/mjnginx.conf',function(err,data){
    if(err){
        return console.log(err);
    }
    console.log(data.toString());
});

fs.readFile('output.txt',function(err,data){
    if(err){
        return console.log(err);
    }
    console.log(data.toString());
});

console.log('程序结束运行');


