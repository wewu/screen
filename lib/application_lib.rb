class ApplicationLib

@@slib = SqlLib.new
@@rows = 16
@@cols = 24
@@log = Logger.new("log/info.log")

## =================== string ===================
def remove_space(val)
   v1 = val.gsub(/^\s*/, '')
   v2 = v1.gsub!(/\s*$/, '')
   v2
end

def match_format(val, reg)
   if (reg.match(val))
      succ = 1
   else
      succ = 0
   end
   succ
end    

def is_nil(str)
   ret = false
   if ((str == nil) || (str == ""))   
      empty = true
   else
      empty = false
   end
   empty
end

def is_nil_log(val, valname)
    valnil = is_nil(val)
    if (valnil)
       write_log_error(valname + " is empty.")
       empty = true
    else
       empty = false
    end
    empty
end

def comb_arr_to_str(sep, arr)
   first = true

   str = ""
   for a in arr
      if (first)
         str = a.to_s
         first = false
      else
         str = str + sep + a.to_s
      end
   end
   str
end

def comb_2cols(sep, t1, t2)
   s = t1 + sep + t2
   s
end

## =================== file ===================

def get_filename_from_fhandler(fhandler)
    fname = fhandler.original_filename
    if (fname != nil)
       f0 = fname.gsub(/^.*(\\|\/)/, '')
       f1 = remove_space(f0)
       f2 = f1.gsub(/[^\w\.\-]/,'_') 
       fnames = f2.split(/\//)
       fname = fnames[0]
    end
    fname
end
  
def get_img_path()
   path = File.dirname(__FILE__) + "/../public/images/"
   path
end

def get_localpath(usname, func)
   fnpath =  FILE_PATH_PREFIX + usname + "/" + func + "/"
   fnpath
end

def clear_dir(path)
    Dir.chdir(path) do
       system("rm *")
    end
end

def read_file(path, fname)
  fname2 = path+fname
  arrstr = read_simple_file(fname2)
end

def read_simple_file(fname)
   begin
      fhandler = File.open(fname, "r")
      ln = fhandler.gets
   rescue EOFError
      fhandler.close
      ln = nil
   end
     
   arrstr = Array.new
   j = 0
   while (ln != nil)
      ln.chomp!
      arrstr[j] = ln
      j = j + 1
      begin
         ln = fhandler.gets
      rescue 
         fhandler.close
      end
   end
   fhandler.close
   arrstr
end

def read_file_short_version(fname, start, length)
   arra = read_simple_file(fname)
   arr2 = Array.new
   for i in (0..length)
     arr2[i] = arra[i+start]
   end
   arr2
end

def write_file(lpath, fname, str)
   f = File.new(lpath+fname, "w")
   f.puts str
   f.close
end

def write_simple_file(fname, str)
   f = File.new(fname, "w")
   f.puts str
   f.close
end

def init_dir(uname)
   fnpath =  FILE_PATH_PREFIX + uname + "/"
    
   isexist = File.exist?(fnpath)
   if (!isexist)   
      Dir.mkdir(fnpath)
      Dir.mkdir(fnpath + "upload")
      Dir.mkdir(fnpath + "r")
   end
end

## =================== example file ===================
def get_examplefile_name(whichone)
     path = File.dirname(__FILE__) + "/../w_data/"
     fname = File.join(path, 'format_' + whichone + '.txt')
end

def read_examplefile_short_version()
   arrformat = Array.new
   for i in (1..4)
      arrstr = read_file_short_version(get_examplefile_name(i.to_s), 2, 3)
      arrformat[i] = comb_arr_to_str("<br> \n", arrstr)
   end
   arrformat
end


## =================== upload ===================
def upload(finhandler, foutname)
    File.open(foutname, "wb")  { |f| f.write(finhandler.read) }
end

def upload_txtfile(localpath, datafile)
    fname = get_filename_from_fhandler(datafile)
    upload(datafile, localpath + fname)
    fname
end

def unzip_file(path, zipfname)
    Dir.chdir(path) do
      begin
         system("unzip " + zipfname)
      rescue
      end
      
      begin
         system("gzip -d " + zipfname)
      rescue
      end

      begin
         system("tar -xf *.tar")
      rescue
      end
      
      begin
         system("rm *.tar")
         system("rm *.zip")
      rescue
      end
    end
end

def upload_zipfile(path, zipfile)
    clear_dir(path)
    zipfname = get_filename_from_fhandler(zipfile)
    upload(zipfile, path + zipfname)
    unzip_file(path, zipfname)
    fnamearr = Dir.entries(path)

    fnarr = Array.new 
    j = 0
    for fn in fnamearr
       if (!(fn.eql?(".")) && !(fn.eql?("..")))
          fnarr[j] = fn
          j = j + 1
       end
    end
    fnarr
end


## =================== array ===================
def arr_add(val, arr)
   arr2 = Array.new
   len = arr.length
   for i in (0..len-1)
      arr2[i+1] = arr[i]
   end
   arr2[0] = val
   arr2
end

def arr_del(idx, arr)
   arr2 = Array.new
   len = arr.length
   j = 0
   for i in (0..len-1)
      if (i != idx)
         arr2[j] = arr[i]
         j = j + 1
      end
   end
   arr2
end

def new_arr2(v0, v1)
   arr = Array.new
   arr[0] = v0
   arr[1] = v1
   arr
end

def new_arr3(v0, v1, v2)
   arr = new_arr2(v0, v1)
   arr[2] = v2
   arr
end

def new_arr4(v0, v1, v2, v3)
   arr = new_arr3(v0, v1, v2)
   arr[3] = v3
   arr
end

def new_arr5(v0, v1, v2, v3, v4)
   arr = new_arr4(v0, v1, v2, v3)
   arr[4] = v4
   arr
end

def new_arr6(v0, v1, v2, v3, v4, v5)
   arr = new_arr5(v0, v1, v2, v3, v4)
   arr[5] = v5
   arr
end

def new_arr7(v0, v1, v2, v3, v4, v5, v6)
   arr = new_arr6(v0, v1, v2, v3, v4, v5)
   arr[6] = v6
   arr
end

def new_arr8(v0, v1, v2, v3, v4, v5, v6, v7)
   arr = new_arr7(v0, v1, v2, v3, v4, v5, v6)
   arr[7] = v7
   arr
end

def new_arr9(v0, v1, v2, v3, v4, v5, v6, v7, v8)
   arr = new_arr8(v0, v1, v2, v3, v4, v5, v6, v7)
   arr[8] = v8
   arr
end

def new_arr10(v0, v1, v2, v3, v4, v5, v6, v7, v8, v9)
   arr = new_arr9(v0, v1, v2, v3, v4, v5, v6, v7, v8)
   arr[9] = v9
   arr
end

def new_arr11(v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10)
   arr = new_arr10(v0, v1, v2, v3, v4, v5, v6, v7, v8, v9)
   arr[10] = v10
   arr
end

def new_arr12(v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11)
   arr = new_arr11(v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10)
   arr[11] = v11
   arr
end

def new_arr16(v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15)
   arr = new_arr12(v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11)
   arr[12]= v12
   arr[13]= v13
   arr[14]= v14
   arr[15]= v15
   arr
end

def new_arr20(v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19)
   arr = new_arr16(v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15)
   arr[16]= v16
   arr[17]= v17
   arr[18]= v18
   arr[19]= v19
   arr
end

def new_arr40(v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, 
              v10, v11, v12, v13, v14, v15, v16, v17, v18, v19,
              v20, v21, v22, v23, v24, v25, v26, v27, v28, v29,
              v30, v31, v32, v33, v34, v35, v36, v37, v38, v39)
   arr = new_arr20(v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19)
   arr[20]= v20
   arr[21]= v21
   arr[22]= v22
   arr[23]= v23
   arr[24]= v24
   arr[25]= v25
   arr[26]= v26
   arr[27]= v27
   arr[28]= v28
   arr[29]= v29
   arr[30]= v30
   arr[31]= v31
   arr[32]= v32
   arr[33]= v33
   arr[34]= v34
   arr[35]= v35
   arr[36]= v36
   arr[37]= v37
   arr[38]= v38
   arr[39]= v39
   arr
end

def new_rowcharr()
   rowcharr = new_arr16("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P")
   rowcharr
end
   
def new_rowcharr_r()
   rowcharr = new_arr16("'A'","'B'","'C'","'D'","'E'","'F'","'G'","'H'","'I'","'J'","'K'","'L'","'M'","'N'","'O'","'P'")
   rowcharr
end

def show_arr(title, arr)
   prn("------------------------")
   prn("array: " + title + ", len=" + arr.length.to_s)
   for a in arr
      prn(a.to_s)
   end
   prn("------------------------")
end


## =================== annotation function ===================
def sub_annarr(row, col, annarr)
   arr = Array.new
   len = annarr.length
   n = 0
   for ann in annarr
      if ((ann.row == row) && (ann.col.to_i == col))
         arr[n] = ann
         n = n + 1
      end
   end
   arr
end

def get_distinct_feature(annarr)
   arrfea = Array.new
   i = 0
   for ann in annarr
      arrfea[i] = ann.fea_name
      i = i + 1
   end
   arrfea.uniq!
   
   ## remove nil, null
   arrfea1 = Array.new
   i = 0
   for fea in arrfea
     if (!(is_nil(fea)))
        arrfea1[i] = fea
        i = i + 1
     end
   end
   arrfea1
end

## =================== log ===================
def write_log(msg)
   $log = $log + msg + "<br>"
end

def write_log_error(msg)
   $log = $log + "ERROR : "
   write_log(msg)
end

## =================== check  ===================
def check_date_format(dt)  # 2007-10-09
   succ = false
   reg = /\d\d\d\d\d\d\d\d/
   if (!(reg.match(dt)))
      succ = false
   else
      succ = true
   end
   succ
end    

## =================== run r  ===================
def qsub(path, prog, out, len)
   Dir.chdir(path) do
      system("rm " + path + out)

      if ($genv == "development")
         rpath = "C:/Program\ Files/R/bin/R.exe"
         cmd = rpath + " --slave -q -f " + prog
         system(cmd)
      else
         ## write a shell 
         sn = srand.to_s
         sn = srand.to_s
         snum = sn[0,5]
         fname = "run" + snum + ".sh"
         
         ## write shell 
         system("rm " + fname)
         f = File.new(fname, "w")
         f.puts "R --slave -f " + path + prog
         f.close
         system("chmod 700 " + fname)
         
         system("/usr/bin/qsub -u wewu -q concur@pbs -l nodes=hsblade6-g " + fname)
         
         str_last = ""
         t = 0
         tlim = len / 2
         while ((!str_last.eql?("##The end") ) && (t <= len))
            sleep 20
            begin
               arrstr = read_simple_file(out)
               if (arrstr.length > 0)
                  str_last = arrstr[arrstr.length-1]
               end
            rescue
            end

            #@@log.info("t=" + t.to_s + ", tlim=" + tlim.to_s + ", last str=" + str_last)
            t = t + 1
        end
      end

      system("chmod 644 *.jpg")
      system("chmod 644 *.pdf")
      system("chmod 644 " + out)

      imgpath = get_img_path()
      system("mv *.jpg " + imgpath)
   end
end
    
def repeat(str, n, sep)
   s = ""
   for i in 0..(n-2)
      s = s + str + sep
   end
   s = s + str
   s
end
## =================== print  ===================
def pr(name, val)
   puts name + "=" + val.to_s + "\n"
end

def prn(val)
   puts val.to_s + "\n"
end

## =============== search ==================
def search_array_num_item(item, arr)
    idx = -1
    j = 0
    for it in arr
       if (it == item)
           idx  = j
           break
       end      
       j = j + 1
    end
    idx
end
   
def search_array_str_item(item, arr)
   idx = -1
   begin
      j = 0
      for a in arr
         if (a.casecmp(item) == 0)
            idx  = j
            break
         end      
         j = j + 1
      end
   rescue
   end
   idx
end

def search_pattern_in_array(reg, arr)
   ret = ""
   begin
      for i in 0..(arr.length - 1)
         matched = reg.match(arr[i])
         if (matched)
            ret = matched[1]
         end
      end
   rescue
   end
   ret
end

def search_patterns_in_array(n, reg, arr)
   retarr = Array.new
   begin
      for i in 0..(arr.length - 1)
         matched = reg.match(arr[i])
         if (matched)
            for j in 1..n
               retarr[j-1] = matched[j]
           end
         end
      end
   rescue
   end
   retarr
end

def msg_box(txt, title, buttons)
   user32 = DL.dlopen('user32')
   msgbox = user32['MessageBoxA', 'ILSSI']
   r, rs = msgbox.call(0, txt, title, buttons)
   return r
end


## ============ module ==================
def get_func_group(func)
   funcgrp = 0
   if ((func == "showraw") || (func == "delete") || (func == "share"))
      funcgrp = 1
   end
   if (func == "qualctrl")
      funcgrp = 2
   end
   if ((func == "POC") || (func == "negatives") || (func == "negmean") || (func == "Bscore") || (func == "zscore")) 
      funcgrp = 3
   end
   funcgrp
end

## ============ date ==================
def get_today_date
   today_date = Time.now
   adate = today_date.strftime("%Y-%m-%d")
   adate
end

end
