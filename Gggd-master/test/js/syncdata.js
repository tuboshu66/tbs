const fs = require("fs");
 
// local path
const conf = require("./conf.json");
 
/**
 * update file
 * @param   res  to update content
 * @returns update operation result
 */
function updateResFile (res) {
    return fs.writeFileSync(`${conf['workdir']}${conf['res']}`, res);
}
 
/**
 * break line append log
 * @param log log content
 * @returns append operation result
 */
function appendFile (log) {
    if ("windows" == conf['os']) {
        log+='\r\n';
    } else {
        log+='\n';
    }
    return fs.appendFileSync(`${conf['workdir']}${conf['log']}`, log);
}
 
/**
 * handle directory
 * @param {*} src 
 * @param {*} dst 
 * @param {*} callback 
 */
function handleDir(src, dst) {
    fs.access(dst, fs.constants.F_OK, (err) => {
        if (err) {
            fs.mkdirSync(dst);
            copyDir(src, dst);
        } else {
            copyDir(src, dst);
        }
    });
}
 
/**
 * execute iterator copy directory
 * @param src directory source path
 * @param dst directory destination path
 * @returns copy result
 */
function copyDir (src, dst) {
    // read file path sync
    let paths = fs.readdirSync(src);
    paths.forEach(function(path){
      var _src=src+'/'+path;
      var _dst=dst+'/'+path;
      
      //stats object, include its own attribute
      fs.stat(_src,function(err,stats){
        if(err) {
            console.log(`copyDir failed, caused by ${JSON.stringify(err)}`);
            return false;
        } else if(stats.isFile()){
          let readable=fs.createReadStream(_src);
          let writable=fs.createWriteStream(_dst);
          readable.pipe(writable);
        }else if(stats.isDirectory()){
          handleDir(_src, _dst, copyDir);
        }
      });
    });
    return true;
}
 
/**
 * read file sync
 * @param path filefullpath
 * @returns file content
 */
function readFile (path) {
    return fs.readFileSync(path, conf['encode']);
}
 
/**
 * main entrance
 */
function syncFile () {
    // test code here
}
 
// call
syncFile ();
 
