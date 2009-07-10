class UploadController < ApplicationController

@@ulib = UploadLib.new
@@alib = ApplicationLib.new
@@slib = SqlLib.new
@@salib = SqlAssayLib.new
@@sarlib = SqlAssayresultLib.new

## ===================== link click ================================

def goto_upload_page
   (func, title) = get_2_params()
   init_globals()

   goto_upload_page1(func, title)
end

def goto_upload_page1(func, title)
   @func = func
   @title = title
   
   if (func == "uploadmul")
      render :action => "upload_multiple"
   
   elsif (func == "uploadsin")
      @dbplatenamearr  = @@slib.sql_get_db_plate_name_arr()
      @pathwaynamearr  = @@slib.sql_get_nstr("pathway", "name", "")
      render :action => "upload_single"
      
   elsif (func == "uploaddat")
      render :action => "upload_data"
   end 
end


## ===================== button upload ==================================
def upload_data_button_onclick
   aname   = @@alib.remove_space(params["tbox_aname"])
   datafile = params["tbox_datfile"]

   error = @@alib.is_nil_log(datafile, "Data File")
   if (!error)
      lpath = @@alib.get_localpath(session[:cas_user], "upload")
      fname = @@alib.upload_txtfile(lpath, datafile)
      pid   = @@slib.sql_get_1num("plate", "plate_id", "name = 'template'")
      pwid = @@slib.sql_get_1num("pathway", "pathway_id", "name='template'")

      assayfields = @@alib.new_arr10(session[:cas_user], fname, aname, 1, pid, "", "", "", pwid, 1)

      @@ulib.load_data(lpath, assayfields)
   end
   
   (func, title) = get_2_params()
   goto_upload_page1(func, title)
end

def upload_multiple_button_onclick
   zipfile = params["tbox_zipfile"]
   prot = params["tbox_protfile"]

   error = @@alib.is_nil_log(zipfile, "Data File")
   if (!error)
      lpath = @@alib.get_localpath(session[:cas_user], "upload")
      arrfname = @@alib.upload_zipfile(lpath, zipfile)
      succ = @@ulib.check_filename_format(arrfname)

      if (succ)
         for fname in arrfname
            (aname, repli, dname, pname, desc, date) = @@ulib.parse_fname(fname)
             pid = @@slib.sql_get_pid_by_dname_and_pname(dname, pname)
             pwid = @@slib.sql_get_1num("pathway", "pathway_id", "name='template'")
                   
             assayfields = @@alib.new_arr10(session[:cas_user], fname, aname, repli, pid, desc, date, prot, pwid, 1)
             @@ulib.load_single(lpath, assayfields)
         end
      end
   end

   arrcur = @@alib.new_arr7("", "", "", "", "", "", "")
   set_globals(arrcur)
   (func, title) = get_2_params()
   goto_upload_page1(func, title)
end

def upload_single_button_onclick
   aname   = @@alib.remove_space(params["tbox_aname"])
   datafile= params["tbox_datafile"]
   repli   = params["list_repli"]
   piddname=params["list_piddname"]
   pwname  = params["list_pwname"]
   prot    = params["tbox_protfile"]
   desc   = params["tbox_adesc"].gsub("'","\'")
   date   = @@alib.remove_space(params["tbox_adate"])

   error = @@alib.is_nil_log(aname,    "Experiment Name")
   if (!error)
      error = @@alib.is_nil_log(datafile, "Data File")
   end
   if (!error)
      error = !(@@alib.check_date_format(date) || @@alib.is_nil(date))
   end
   if (!error)
      error = @@alib.is_nil_log(repli, "Replicate")
   end
   if (!error)
      error = @@alib.is_nil_log(piddname, "Plate") 
   end
   if (!error)
      error = @@alib.is_nil_log(pwname, "Pathway") 
   end
   
   if (!error)
      lpath = @@alib.get_localpath(session[:cas_user], "upload")
      fname = @@alib.upload_txtfile(lpath, datafile)
      (pid, tmp) = piddname.split(/\:/)
      pwid = @@slib.sql_get_1num("pathway", "pathway_id", "name='" + pwname + "'")
      
      assayfields = @@alib.new_arr10(session[:cas_user], fname, aname, repli, pid, desc, date, prot, pwid, 1)
      @@ulib.load_single(lpath, assayfields)
   end  
   
   arrcur = @@alib.new_arr7(aname, repli, piddname, desc, date, prot, pwname)
   set_globals(arrcur)
   (func, title) = get_2_params()
   goto_upload_page1(func, title)
end

## ===================== other link ================================
  
def convention_link_onclick
   @dbplatenamearr  = @@slib.sql_get_db_plate_name_arr()
   render :action => "convention"
end


## ===================== global ================================
def init_globals
   $log = ""
   arrcur = @@alib.new_arr7("","","","","","","")
   set_globals(arrcur)
end

def set_globals(arrcurval)
   $curaname = arrcurval[0]
   $currepli = arrcurval[1]
   $curpiddname = arrcurval[2]
   $curadesc = arrcurval[3]
   $curadate = arrcurval[4]
   $curprot = arrcurval[5]
   $curpwname = arrcurval[6]
end

def show_examplefile_link_onclick
   fname = @@alib.get_examplefile_name(params[:id])
   send_file (fname)
end

def get_2_params()
   func = params[:func]
   title = params[:title]
   
   arr = Array.new
   arr[0] = func
   arr[1] = title
   arr
end

def main
   render :action => "main"
end

end  #class end


