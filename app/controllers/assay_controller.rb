class AssayController < ApplicationController

@@alib = ApplicationLib.new
@@slib = SqlLib.new
@@salib = SqlAssayLib.new
@@sarlib = SqlAssayresultLib.new
@@rlib = RLib.new
@@rows = 16
@@cols = 24


## ===================== link click ================================
def goto_select_page   #(func, title)
   (func, title) = get_2_params()
   goto_select_page1(func, title)
end

def goto_select_page1(func, title)   
   @func = func
   @title = title

   anmarr = ""
   if ((@func == "share") || (@func == "delete") || (@func == "qualctrl") || (@func == "assign")) 
      anmarr = @@slib.sql_get_nstr("assay", "distinct concat(name, ' (', user_id, ')')", " user_id = '" + session[:cas_user] + "'")
      @share = 0
   else
      anmarr = @@slib.sql_get_nstr("assay", "distinct concat(name, ' (', user_id, ')')", " share=1 or user_id = '" + session[:cas_user] + "'")
      @share = 1
   end    
   
   if (func == "assign")
      @anamearr = anmarr
   else
      @anamearr = @@alib.arr_add("*", anmarr)
   end
   @dnamearr = @@alib.arr_add("*", @@slib.sql_get_nstr_order("biodatabase", "name", "", "biodatabase_id"))
   @pwnamearr= @@alib.arr_add("*", @@slib.sql_get_nstr("pathway", "name", ""))
   @descarr  = @@alib.arr_add("*", @@slib.sql_get_nstr("assay", "distinct assay_desc", "assay_desc <> ''"))
   @datearr  = @@alib.arr_add("*", @@slib.sql_get_nstr("assay", "distinct assay_date", ""))

   render :action => "select"
end


def goto_list_page  #(func, title, aidstr_list)
   (func, title, aidstr_list) = get_3_params()
   goto_list_page1(func, title, aidstr_list, 0)
end
   
def goto_list_page1(func, title, aidstr_list, done)
   @func = func
   @title = title
   @aidstr_list = aidstr_list
   @done = done

   @aarr_list = @@salib.select_by_aidstr(aidstr_list)
   len = @aarr_list.length
   @subgroup_arr = @@alib.new_arr40("1","2","3","4","5","6","7","8","9",
                                    "10","11","12","13","14","15","16","17","18","19",
                                    "20","21","22","23","24","25","26","27","28","29",
                                    "30","31","32","33","34","35","36","37","38","39","40")
   render :action => "assay_list"
end


## --------------------- 2. assay list page --------------------------
def show_button_onclick
   (func, title, aidstr_list) = get_3_params()
   
   aidarr_sel = selected_assay_cbox(aidstr_list)
   aidstr_sel = @@alib.comb_arr_to_str("_", aidarr_sel)
   cutoff = get_cutoff_value(func)
   subgrparr_sel = selected_subgroup_list(aidstr_list)
   
   goto_result_page1(func, title, aidstr_list, aidstr_sel, cutoff, "", 0, subgrparr_sel)
end

def goto_result_page  #(func, title, aidstr_list, aidstr_sel, cutoff)
   (func, title, aidstr_list, aidstr_sel, cutoff, outfname) = get_6_params()
   goto_result_page1(func, title, aidstr_list, aidstr_sel, cutoff, outfname, 0, "")
end

def goto_result_page1(func, title, aidstr_list, aidstr_sel, cutoff, outfname, done, subgrparr_sel)
   @func = func
   @title = title
   @aidstr_list = aidstr_list
   @aidstr_sel = aidstr_sel 
   @cutoff = cutoff
   @outfname = outfname
   @done = done

   if (@func == "share")
      do_share(@aidstr_list)
      goto_list_page1(@func, @title, @aidstr_list, 1)

   elsif (@func == "delete")
      do_delete(@aidstr_sel)
      goto_list_page1(@func, @title, @aidstr_list, 1)
            
   else
       aidarr = aidstr_sel.split("_")
       if (aidarr.length > 0)
           if (@func == "showraw")
              render :action => "raw_result"

           elsif (@func == "qualctrl")
              render :action => @func + "_result"
      
           else      ## analysis group
              if (@@alib.is_nil(@outfname))
                 @outfname = @@rlib.run_r(session[:cas_user], @func, @cutoff, aidarr, subgrparr_sel)
              end
              @arrdata = get_rout_dataarr(@outfname)
              if (@arrdata.length > 0)
                 @idxarr = @@rlib.get_avg_idxarr(@arrdata)
                 render :action => "score_result"
              else
                 render :action => "timeout"
              end
           end
      else
           goto_list_page1(@func, @title, @aidstr_list, 0)
      end
   end
end


def goto_result_2_page    #(func, title, aidstr_list, aidstr_sel, cutoff, outfname, idx)
   (func, title, aidstr_list, aidstr_sel, cutoff, outfname) =  get_6_params()
   subfunc = params[:subfunc]
   subtitle = params[:subtitle]
   idxstr = params[:idxstr]
   goto_result_2_page1(func, title, aidstr_list, aidstr_sel, cutoff, outfname, subfunc, subtitle, idxstr)
end

def goto_result_2_page1(func, title, aidstr_list, aidstr_sel, cutoff, outfname, subfunc, subtitle, idxstr)
   @func = func
   @title = title
   @aidstr_list = aidstr_list
   @aidstr_sel = aidstr_sel 
   @cutoff = cutoff
   @outfname = outfname
   @subfunc = subfunc
   @subtitle = subtitle
   @idxarr = idxstr.split(/\_/)
   
   @arrdata = @@alib.read_simple_file(outfname)
   if (@arrdata.length > 0)
      render :action => "score_result_2"
   else
      render :action => "timeout"
   end
end

def download_link_onclick
   func = params[:func]
   outfname = params[:outfname]
   idxstr = params[:idxstr]
   idxarr = idxstr.split(/\_/)

   arrdata = @@alib.read_simple_file(outfname)

   fname = params[:fname]
   send_file (fname)
end

def protocol_link_onclick()
   (@func, @title, @aidstr_list) = get_3_params()
   
   @aid = params[:aid]
   @prot = params[:prot]
   @prot.gsub!(/\n/, "<br>")
   render :action => "protocol"
end


## ===================== button click ================================
## ---------------------1. select page -------------------------------
def select_button_onclick
   (func, title) = get_2_params()
   share = params[:share]
   aname_userid = params["list_aname"]
   (aname, userid) = aname_userid.split(" ")
   
   if (func == "assign")
      select_button_onclick_assign(func, title, aname)
   else
      select_button_onclick_2(func, title, aname, share)
   end
end

def select_button_onclick_2(func, title, aname, share)
   dname = params["list_dname"]
   pwname= params["list_pwname"]
   desc  = params["list_desc"]
   date  = params["list_date"]
   
   aidarr_list = @@salib.select_aid_by_filter(session[:cas_user], aname, dname, pwname, desc, date, share)
   aidstr_list = @@alib.comb_arr_to_str("_", aidarr_list)
   
   #funcgrp = @@alib.get_func_group(func)
   #if (funcgrp == 3)  #analysis group
   #   cutoff = get_cutoff_value(func)
   #   #aidstr_sel = aidstr_list
   #   #goto_result_page1(func, title, aidstr_list, aidstr_sel, cutoff, "", 0)
   #end

   aidarr_sel  = selected_assay_cbox(aidstr_list)
   aidstr_sel = @@alib.comb_arr_to_str("_", aidarr_sel)
   goto_list_page1(func, title, aidstr_list, 0)
   
end

def select_button_onclick_assign(func, title, aname)
   machine = params["cbox_machine"]
   goto_assign_page(func, title, aname, machine, 1, 0)
end

def goto_assign_page(func, title, aname, machine, cur_libid, assigned)
   @func = func
   @title = title
   @aname = aname
   @machine = machine
   @assigned = assigned

   aidarr_has_rawplate = @@slib.sql_get_nnum("assay_feature", "distinct assay_id", "name='plate_id'")
   aidarr_str_has_rawplate = @@alib.comb_arr_to_str(",", aidarr_has_rawplate)

   aidarr = @@slib.sql_get_nnum("assay", "assay_id", "name = '" + @aname + "' and user_id = '" + session[:cas_user] + "' and assay_id in (" + aidarr_str_has_rawplate + ")")
   @aidstr_list = @@alib.comb_arr_to_str("_", aidarr)
   @cur_libname =  @@slib.sql_get_1str("biodatabase", "name", "biodatabase_id = " + cur_libid.to_s)
   @libname_arr = @@slib.sql_get_nstr_order("biodatabase",  "name", "name <> 'template'", "biodatabase_id")
   
   @platename_arr = @@slib.sql_get_nstr_order("plate", "name", "biodatabase_id = " + cur_libid.to_s, "name")
   @replicate_arr = @@alib.new_arr10("1","2","3","4","5","6","7","8","9","10") 
   @pathway_arr = @@slib.sql_get_nstr_order("pathway", "name", "name <> 'template'", "name")
   
   if ((@machine == "1") && (aidarr.length > 0))
      aidstr = @@alib.comb_arr_to_str(",", aidarr)
      @paramname_arr = @@slib.sql_get_nstr_order("assay_feature", "distinct name", "assay_id in (" + aidstr + ")", "name")
   else
      @paramname_arr = ""
   end
   
   render :action => "assign"
end

def update_plate_button_onclick()
   (func, title) = get_2_params()
   aname = params[:aname]
   machine = params[:machine]
   libname = params["list_lib"]
   cur_libid =  @@slib.sql_get_1num("biodatabase", "biodatabase_id", "name = '" + libname + "'")

   goto_assign_page(func, title, aname, machine, cur_libid, 0)
end

def assign_button_onclick()
   (func, title, aidstr_list) = get_3_params()
   aname = params[:aname]
   machine = params[:machine]
   
   libname = params[:cur_libname]
   libid =  @@slib.sql_get_1num("biodatabase", "biodatabase_id", "name = '" + libname + "'")
   
   aidarr =  aidstr_list.split("_")
   for aid in aidarr
      platename = params["list_plate_" + aid.to_s]
      plateid = @@slib.sql_get_1num("plate", "plate_id", "biodatabase_id = " + libid.to_s + " and name = '" + platename + "'")
      replicate = params["list_rep_" + aid.to_s]
      pwname = params["list_pw_" + aid.to_s]
      pwid = @@slib.sql_get_1num("pathway", "pathway_id", "name='" + pwname + "'")
      adate = params["tbox_date_" + aid.to_s]
      adesc = params["tbox_des_" + aid.to_s]
      proto = params["tbox_prot_" + aid.to_s]
      
      @@salib.update_plate(aid, plateid, replicate, pwid, adate, adesc, proto)
      elemarr = @@sarlib.list_element(aid)
      @@sarlib.update_element(plateid, elemarr)
   end     

   goto_assign_page(func, title, aname, machine, libid, 1)
end

## --------------------- 3. qualctrl page --------------------------
def qc_submit_button_onclick
   aidstr_sel = params[:aidstr_sel]
   aidarr = aidstr_sel.split("_")
   applyall = params["cbox_applyall"]

   if (aidarr.length > 0)
      aid0 = aidarr[0]
      if (applyall == "1")
         for aid in aidarr
           qc_update_an_assay(aid, aid0)
         end
      else
         qc_update_an_assay(aid0, aid0)
      end
   end
   
   (func, title, aidstr_list) = get_3_params()
   
   goto_result_page1(func, title, aidstr_list, aidstr_sel, "", "", 1)
end

def qc_update_an_assay(aid, aid0)
   rowcharr = @@alib.new_rowcharr()
   pid = @@slib.sql_get_1num("assay", "plate_id", "assay_id=" + aid.to_s)
   for i in (0..@@rows-1)
      for j in (0..@@cols-1)
         pos = aid0.to_s + "_" + (i*@@cols+j).to_s 
         bc = get_bc_val(pos)
         if (bc >= 0)
            bcdesc = params["tbox_" + pos]
            eid = @@slib.sql_get_eid(pid, rowcharr[i], j+1)
            @@sarlib.update_bc(aid, eid, bcdesc, bc);
         end
      end
   end
end

## ===================== small functions ================================
def is_cbox_checked(aid)
  if (params["cbox_" + aid.to_s] == "1")
     ret = true
  else
     ret = false
  end
  ret
end

def is_rbox_checked(aid)
  if (params["rbox"] == aid.to_s)
     ret = true
  else
     ret = false
  end
  ret
end

def selected_assay_cbox(aidarrstr)
   aidarr = aidarrstr.split("_")
   aidarrsel = Array.new
   j = 0
   for aid in aidarr
      ckc = is_cbox_checked(aid)
      ckr = is_rbox_checked(aid)
      if (ckc || ckr)
         aidarrsel[j] = aid
         j = j + 1
      end
   end
   aidarrsel
end

def selected_subgroup_list(aidarrstr)
   aidarr = aidarrstr.split("_")
   subgrp_arr = Array.new

   j = 0
   for aid in aidarr
      ckc = is_cbox_checked(aid)
      ckr = is_rbox_checked(aid)
      if (ckc || ckr)
         subgrp_arr[j] = params["list_subgroup_" + aid.to_s]
         j = j + 1
      end
   end
   subgrp_arr
end

def get_cutoff_value(func)
   funcgrp = @@alib.get_func_group(func)
   if (funcgrp == 3)
      cutoff = params["tbox_cutoff"].to_f
   else
      cutoff = "NA"
   end
   cutoff
end

def convert_cutoff(cutoff)
  if (cutoff == "99%")
     val = 2.57
  elsif (cutoff == "95%")
     val = 1.96
  elsif (cutoff == "90%")
     val = 1.64
  else
     val = cutoff.to_i
  end
  val
end

def get_rout_dataarr(outfname)
   t = 0
   while ((!File.exist?(outfname)) && t < 5)
      puts "waiting for R result: sleep 4"
      system("sleep 4")
      t = t + 1
   end
   if (t < 5)
      arrdata = @@alib.read_simple_file(outfname)
   else
      arrdata = ""
   end
   arrdata
end

def get_bc_val(pos)
   bdval = params["cbox_bd_" + pos]
   pcval = params["cbox_pc_" + pos]
   ncval = params["cbox_nc_" + pos]
   if (bdval == "1")
      bc = 1
   elsif (pcval == "1")
      bc = 2
   elsif (ncval == "1")
      bc = 3
   else 
      bc = 0
   end
   bc
end

def send_image_file
   fname = params[:fname]
   send_file (fname)
end

def send_annotation_file
   fname = params[:fname]
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

def get_3_params()
   (func, title) = get_2_params()
   aidstr_list = params[:aidstr_list]
   
   arr = Array.new
   arr[0] = func
   arr[1] = title
   arr[2] = aidstr_list
   arr
end

def get_6_params()
   (func, title, aidstr_list) = get_3_params()
   
   arr = Array.new
   arr[0] = func
   arr[1] = title
   arr[2] = aidstr_list
   arr[3] = params[:aidstr_sel]
   arr[4] = params[:cutoff]
   arr[5] = params[:outfname]
   arr
end


## ===================== do functions ================================
def do_share(aidstr_list)
   aidarr = aidstr_list.split("_")
   for aid in aidarr 
      ckc = is_cbox_checked(aid)
      if (ckc)
         @@salib.update_share(aid, 1)
      else
         @@salib.update_share(aid, 0)
      end
   end
end

def do_delete(aidstr_sel)
   aidarr = aidstr_sel.split("_")
   if (aidarr.length > 0)
      #button_yesno = 4
      #click_yes = 6
      #click_no = 7
      #response = @@alib.msg_box("Are you sure you want to delete?", "Delete?", button_yesno)

      #if (response == click_yes)
         for aid in aidarr 
            @@sarlib.delete(aid)
            @@salib.delete_feature(aid)
            @@salib.delete(aid)
         end
      #end
   end
end

end
