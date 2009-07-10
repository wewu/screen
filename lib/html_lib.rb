class HtmlLib
require 'dl'

@@alib = ApplicationLib.new
@@slib = SqlLib.new
@@salib = SqlAssayLib.new
@@sarlib = SqlAssayresultLib.new
@@rlib = RLib.new
@@rows = 16
@@cols = 24

## ================ assay table ================================
def assay_head_cols
   headarr = @@alib.new_arr10("Experiment", "Repl.", "Library", "Plate", "Pathway", 
                             "Desc", "Date", "owner", "Pos. ctrl", "Neg. ctrl")
   str = ""
   for txt in headarr
      str = str + textb_col(txt)
   end
   str
end

def assay_head_row
   s = make_row(assay_head_cols(), 2)
end

def assay_rec_cols(ass)
   recarr = @@alib.new_arr8(ass.assay_name, ass.replicate, ass.biodatabase_name, 
                            ass.plate_name, ass.pathway_name, ass.assay_desc, 
                            ass.assay_date, ass.user_id)
   str = ""
   i = 0
   for a in recarr
      str = str + text_col(a.to_s)
      i = i + 1
   end
   posctrlstr = @@alib.comb_arr_to_str(",", @@sarlib.list_posctrl_elem(ass.assay_id))
   negctrlstr = @@alib.comb_arr_to_str(",", @@sarlib.list_negctrl_elem(ass.assay_id)) 
   str = str + text_col(posctrlstr) 
   str = str + text_col(negctrlstr) 
   str
end

def assay_rec_row(ass, bgcolor)
   str = make_row(assay_rec_cols(ass), bgcolor)
end

## ================ assay_result table ================================
def ar_head_cols()
   s = texts2b_col("")
   for j in (0..(@@cols-1))
      s = s + texts2b_col((j+1).to_s)
      if (j==(@@cols-1))
         s = s + texts2b_col("")
      end
   end
   s
end

def ar_head_row()
   s = make_row(ar_head_cols(), 2)
end

def ar_rec_cols(i, arvalarr, colortype)
   s = ""
   for j in (0..(@@cols-1))
      val = arvalarr[i*@@cols+j].to_s
      color = get_color(val, colortype)
      s = s + texts2right_color_col(val, color)
   end
   s
end

def ar_rec_cols_b(i, arvalarr, colortype)
   s = ""
   for j in (0..(@@cols-1))
      val = arvalarr[i*@@cols+j].to_s
      color = get_color(val, colortype)
      s = s + texts2b_color_col(val, color)
   end
   s
end

def ar_rec_row(i, arvalarr, colortype)
   rowcharr = @@alib.new_rowcharr()
   rlabel = texts2b_col(rowcharr[i])
   s = make_row(rlabel + ar_rec_cols(i, arvalarr, colortype) + rlabel, i % 2)
end

def ar_rec_rows(arvalarr, colortype)
   s = ""
   for i in 0..(@@rows-1)
      s = s + ar_rec_row(i, arvalarr, colortype)
   end
   s
end

def ar_table(arvalarr, colortype)
   s = "<table border=1>\n"
   s = s + ar_head_row()
   s = s + ar_rec_rows(arvalarr, colortype)
   s = s + "</table><br>\n"
   s = s + show_color_label(colortype)
   s
end


## ================ rawval table ================================
def rawval_head_row()
   s = make_row("<td></td>" + ar_head_cols(), 2)
   s
end

def rawval_coleff_row(coleffarr)
   s = "<td></td>" 
   s = s + textb_col("Effect")
   s = s + ar_rec_cols_b(0, coleffarr, "0")
   s
end

def rawval_rec_row(i, rowlabel, roweff, arvalarr, colortype)
   color = get_color(roweff, "0")
   
   rlabel = texts2b_col(rowlabel)           #row label
   reffval = texts2b_color_col(roweff, color)  #row effect
   colrecrow = ar_rec_cols(i, arvalarr, colortype)
   s = make_row(rlabel + reffval + colrecrow + rlabel, i % 2)
   s
end

def rawval_rec_rows(roweffarr, arvalarr, colortype)
   rowcharr = @@alib.new_rowcharr()
   s = ""
   for row in (0..@@rows-1)
      s = s + rawval_rec_row(row, rowcharr[row], roweffarr[row], arvalarr, colortype)
   end 
   s
end

def rawval_table(roweffarr, coleffarr, arvalarr, colortype)
   s = "<table border=1>\n"
   s = s + rawval_head_row()
   s = s + rawval_coleff_row(coleffarr)
   s = s + rawval_rec_rows(roweffarr, arvalarr, colortype)
   s = s + "</table><br>\n"
   s
end

def show_rawvalue_table(func, aid, colortype)
    anm = @@salib.select_aname(aid)
    rid = @@salib.select_rid(aid)

    scorearr = @@sarlib.list_value(aid)  #control well value = "NA"
    roweff = @@rlib.get_roweff(scorearr)
    coleff = @@rlib.get_coleff(scorearr)

    scoretab_str = rawval_table(roweff, coleff, scorearr, colortype) 

    s = ""
    s = s + show_aname(anm)
    s = s + show_rid(rid)
    s = s + scoretab_str
    s
end

## ================ qualctr table ================================

def qc_head_cols()
   s = ""
   for j in (0..(@@cols-1))
      if (j%5 == 0)
         s = s + texts2_col("")
      end
      s = s + texts2b_col((j+1).to_s)
      s = s + texts2b_col("Bad") + texts2b_col("Pos") + texts2b_col("Neg") + texts2b_col("Desc")
      s = s + texts2b_col("")
   end
   s
end

def qc_head_row()
   s = make_row(qc_head_cols(), 2)
end

def qc_rec_cols(aid, i, ararr)
   rowcharr = @@alib.new_rowcharr()
   s = ""
   for j in (0..(@@cols-1))
      if (j%5 == 0)
         s = s + texts2b_color_col(rowcharr[i], "blue")
      end
      n = i*@@cols + j
      pos = aid.to_s+"_"+n.to_s
      s = s + texts2_col(ararr[n].value.to_s)
      if (ararr[n].bc_elem.to_i == 1)
         s = s + cboxchked_col("cbox_bd_"+pos, "1")
         s = s + cbox_col("cbox_pc_"+pos, "1")
         s = s + cbox_col("cbox_nc_"+pos, "1")
      elsif (ararr[n].bc_elem.to_i == 2)
         s = s + cbox_col("cbox_bd_"+pos, "1")
         s = s + cboxchked_col("cbox_pc_"+pos, "1")
         s = s + cbox_col("cbox_nc_"+pos, "1")
      elsif (ararr[n].bc_elem.to_i == 3)
         s = s + cbox_col("cbox_bd_"+pos, "1")
         s = s + cbox_col("cbox_pc_"+pos, "1")
         s = s + cboxchked_col("cbox_nc_"+pos, "1")
      else
         s = s + cbox_col("cbox_bd_"+pos, "1")
         s = s + cbox_col("cbox_pc_"+pos, "1")
         s = s + cbox_col("cbox_nc_"+pos, "1")
      end
      s = s + tbox_col("tbox_"+pos, ararr[n].bc_elem_desc, 3)
      s = s + texts2_col("")
   end
   s
end

def qc_rec_row(aid, i, ararr)
   s = make_row(qc_rec_cols(aid, i, ararr), i%2)
end

def qc_rec_rows(aid, ararr)
   s = ""
   for i in 0..(@@rows-1)
      s = s + qc_rec_row(aid, i, ararr)
   end
   s
end

def qc_table(aid, ararr)
   s = "<table border =1>\n"
   s = s + qc_head_row()
   s = s + qc_rec_rows(aid, ararr)
   s = s + "</table><br>\n"
   s
end

def show_qc_table(aid, ararr)
   s = show_table_head(aid)
   s = s + qc_table(aid, ararr)
   s
end

## ================ show function ================================
def show_table_head(aidarr_str)
   (aid, anm, ridstr, pnamestr) = @@rlib.get_aname_rid_pname(aidarr_str)        
    s = ""
    s = s + show_aname(anm)
    s = s + show_rid(ridstr)
    s = s + show_pname(pnamestr)
    s
end

def show_score_table(func, aidarr_str, scorearr, colortype)
   shead = show_table_head(aidarr_str)
   sval = ar_table(scorearr, colortype) 
   s = shead + sval
   s
end

## ================ plain text table ================================
def plaintext_head_row(func)
   s = ""
   s = s + "row" + "\t"
   s = s + "col" + "\t"
   s = s + func  + "\n"
   s
end

def plaintext_rec_row(row, col, score)
   s = ""
   s = s + row + "\t"
   s = s + col + "\t"
   s = s + score.to_s + "\t"
   s = s + texts2_col("")
   s = s + texts2_col(annarr[0].be_name)
   if (@@alib.is_nil(annarr[0].accession))
      s = s + texts2_col("")
   else
      s = s + texts2_http_col(annarr[0].accession, "http://www.ncbi.nlm.nih.gov/sites/entrez?db=gene&cmd=search&term="+annarr[0].accession.to_s)
   end
   s = s + texts2right_col(annarr[0].sample_id)
   s = s + texts2left_col(annarr[0].sequence)
   s = s + texts2left_col(annarr[0].db_name)
   s = s + texts2_col("")

   ## feature array
   len = annarr.length
   for fea in feanamearr
      found = false
      for j in 0..(len-1)
         if (fea == annarr[j].fea_name)
            s = s + texts2left_col(annarr[j].fea_value)
            found = true
         end
      end
      if (found == false)
         s = s + texts2_col("")
      end
   end
   s
end

## ================ annotation page ================================
def ann_head_cols(func, feanamearr)
   s = ""
   s = s + texts2b_col("row")
   s = s + texts2b_col("col")
   s = s + texts2b_col(func)
   s = s + texts2b_col("")
   s = s + texts2b_col("Name")
   s = s + texts2b_col("Accession")
   s = s + texts2b_col("SampleID")
   s = s + texts2b_col("Sequence")
   s = s + texts2b_col("Library")
   s = s + texts2b_col("")

   for fea in feanamearr
      s = s + texts2b_col(fea.capitalize)
   end
   s
end

def ann_head_row(func, feanamearr)
   s = make_row(ann_head_cols(func, feanamearr), 2)
end


def ann_rec_cols(i, row, col, score, annarr, feanamearr)
   s = ""
   s = s + texts2_col(row)
   s = s + texts2_col(col)
   s = s + texts2_col(score)
   s = s + texts2_col("")
   if (@@alib.is_nil(annarr[0].be_name))
      s = s + texts2_col("")
   else
      s = s + texts2_http_col(annarr[0].be_name, "http://www.ncbi.nlm.nih.gov/sites/entrez?db=gene&cmd=search&term=" + annarr[0].be_name.to_s)  
   end
   s = s + texts2left_col(annarr[0].accession);
   s = s + texts2left_col(annarr[0].sample_id)
   s = s + texts2left_col(annarr[0].sequence)
   s = s + texts2left_col(annarr[0].db_name)
   s = s + texts2_col("")

   ## feature array
   len = annarr.length
   for fea in feanamearr
      found = false
      for j in 0..(len-1)
         if (fea == annarr[j].fea_name)
            s = s + texts2left_col(annarr[j].fea_value)
            found = true
         end
      end
      if (found == false)
         s = s + texts2_col("")
      end
   end
   s
end


def ann_rec_1row(i, row, col, score, annarr, feanamearr)
   s = make_row(ann_rec_cols(i, row, col, score, annarr, feanamearr), i%2)
end            

def ann_rec_rows(annarr, scorearr, feanamearr, cutoff)
   s = ""
   k = 0
   rowcharr = @@alib.new_rowcharr()
   for i in 0..(@@rows-1)
      row = rowcharr[i]
      for j in 0..(@@cols-1)
         idx = i * @@cols + j
         if (scorearr[idx].to_f.abs >= cutoff.to_f) 
            annarr1 = @@alib.sub_annarr(row, j+1, annarr)
            s = s + ann_rec_1row(k, row, j+1, scorearr[idx], annarr1, feanamearr)
            k = k + 1
         end
      end
   end
   s
end

def ann_table(func, annarr, scorearr, feanamearr, cutoff)
   s = "<table border =1>\n"
   s = s + ann_head_row(func, feanamearr)
   s = s + ann_rec_rows(annarr, scorearr, feanamearr, cutoff)
   s = s + "</table><br>\n"
   s
end
    
def show_ann_table(func, aidarr_str, scorearr, cutoff, fname)
   (aid, aname, ridstr, pnamestr) = @@rlib.get_aname_rid_pname(aidarr_str)        
   annarr = @@slib.sql_select_annotation(aid)
   feanamearr = @@alib.get_distinct_feature(annarr)

   sw = write_ann_table(func, annarr, scorearr, feanamearr, cutoff)
   @@alib.write_simple_file(fname, sw)
   
   s = show_table_head(aidarr_str)
   s = s + ann_table(func, annarr, scorearr, feanamearr, cutoff)
   s
end


## ================ write annotation page ================================
def write_ann_table(func, annarr, scorearr, feanamearr, cutoff)
   sw = write_ann_head_row(func, feanamearr)
   sw = sw + write_ann_rec_rows(annarr, scorearr, feanamearr, cutoff)
   sw
end

def write_ann_head_row(func, feanamearr)
   sw = ""
   sw = @@alib.comb_2cols("\t", sw, "row")
   sw = @@alib.comb_2cols("\t", sw, "col")
   sw = @@alib.comb_2cols("\t", sw, func)
   sw = @@alib.comb_2cols("\t", sw, "")
   sw = @@alib.comb_2cols("\t", sw, "Name")
   sw = @@alib.comb_2cols("\t", sw, "Accession")
   sw = @@alib.comb_2cols("\t", sw, "SampleID")
   sw = @@alib.comb_2cols("\t", sw, "Sequence")
   sw = @@alib.comb_2cols("\t", sw, "Library")
   sw = @@alib.comb_2cols("\t", sw, "")
   for fea in feanamearr
      sw = @@alib.comb_2cols("\t", sw, fea.capitalize)
   end
   sw = sw + "\n"
   sw
end


def write_ann_rec_rows(annarr, scorearr, feanamearr, cutoff)
   sw = ""
   k = 0
   rowcharr = @@alib.new_rowcharr()
   for i in 0..(@@rows-1)
      row = rowcharr[i]
      for j in 0..(@@cols-1)
         idx = i * @@cols + j
         if (scorearr[idx].to_f.abs >= cutoff.to_f) 
            annarr1 = @@alib.sub_annarr(row, j+1, annarr)
            sw = sw + write_ann_rec_1row(k, row, j+1, scorearr[idx], annarr1, feanamearr)
            k = k + 1
         end
      end
   end
   sw
end

def write_ann_rec_1row(i, row, col, score, annarr, feanamearr)
   sw = ""
   sw = @@alib.comb_2cols("\t", sw, row.to_s)
   sw = @@alib.comb_2cols("\t", sw, col.to_s)
   sw = @@alib.comb_2cols("\t", sw, score.to_s)
   sw = @@alib.comb_2cols("\t", sw, "")
   if (@@alib.is_nil(annarr[0].be_name))
      sw = @@alib.comb_2cols("\t", sw, "")
   else
      sw = @@alib.comb_2cols("\t", sw, annarr[0].be_name)
   end
   sw = @@alib.comb_2cols("\t", sw, annarr[0].accession.to_s)
   sw = @@alib.comb_2cols("\t", sw, annarr[0].sample_id.to_s)
   sw = @@alib.comb_2cols("\t", sw, annarr[0].sequence.to_s)
   sw = @@alib.comb_2cols("\t", sw, annarr[0].db_name)
   sw = @@alib.comb_2cols("\t", sw, "")

   ## feature array
   len = annarr.length
   for fea in feanamearr
      found = false
      for j in 0..(len-1)
         if (fea == annarr[j].fea_name)
            sw = @@alib.comb_2cols("\t", sw, annarr[j].fea_value.to_s)
            found = true
         end
      end
      if (found == false)
         sw = @@alib.comb_2cols("\t", sw, "")
      end
   end
   sw = sw + "\n"
   sw
end




## ================ example file table function ================================
def examplefile_table(arrformat)
   s = "<table>"
   s = s + texts2left_row("===============================================") 
   s = s + textb_row("Examples of Four Data File Formats: ") 
   
   for i in (1..4)
      s = s + texts2left_color_row("Format " + (i+64).chr, "blue") 
      s = s + texts2left_row(arrformat[i]) 
   end
   s = s + "</table>"
   s
end


## ================ small sql function ================================
def form_db_plate_list(dbplnamearr)
   arrp = form_db_plate_list_2(dbplnamearr)
   len = dbplnamearr.length
   for i in 0..(len-1)
      arrp[i] = dbplnamearr[i].pid.to_s+":" + arrp[i]
   end 
   arrp
end
  
def form_db_plate_list_2(dbplnamearr)
   arrp = Array.new
   len = dbplnamearr.length
   for i in 0..(len-1)
      arrp[i] = dbplnamearr[i].dname + "_" + dbplnamearr[i].pname
   end 
   arrp
end

## ================ form function ================================
def text_col(txt)
   str = "<td nowrap>" + txt + "</td>\n"
end

def text_row(txt)
   s = make_row(text_col(txt), 0)
end

def text_alignright_col(txt)
   str = "<td nowrap align=right>" + txt + "</td>\n"
end

##textb
def textb_col(txt)
   str = "<td nowrap><b>" + txt + "</b></td>\n"
end

def textb_row(txt)
   s = make_row(textb_col(txt), 0)
end

## texts2
def texts2_col(txt)
   str = "<td nowrap align=right><font size=2>" + txt.to_s + "</font></td>"
end

def texts2_row(txt)
   s = make_row(texts2_col(txt), 0)
end

def texts2_http_col(txt, http)
   str = "<td nowrap align=left><font size=2><a href='" + http + "' target='_blank'>" + txt.to_s + "</a></font></td>"
end

target="_blank"
def texts2left_col(txt)
   str = "<td nowrap align=left><font size=2>" + txt.to_s + "</font></td>"
end

def texts2left_row(txt)
   str = make_row(texts2left_col(txt), 0)
end

def texts2right_col(txt)
   str = "<td nowrap align=right><font size=2>" + txt.to_s + "</font></td>"
end

def texts2right_row(txt)
   str = make_row(texts2right_col(txt), 0)
end

def texts2right_color_col(txt, color)
   str = "<td nowrap align=right><font size=2 color='" + color + "'>" + txt.to_s+ "</font></td>"
end

def texts2left_color_col(txt, color)
   str = "<td nowrap align=left><font size=2 color='" + color + "'>" + txt.to_s+ "</font></td>"
end

def texts2left_color_row(txt, color)
   s = "<tr>" + texts2left_color_col(txt, color) + "</tr>"
end

def texts2_color_row(txt, color)
   s = "<tr>" + texts2right_color_col(txt, color) + "</tr>"
end

## texts2b
def texts2b_col(txt)
   str = "<td nowrap align=center><font size=2><b>" + txt.to_s + "</b></font></td>"
end

def texts2b_row(txt)
   s = make_row(texts2b_col(txt))
end

def texts2b_color_col(txt, color)
   str = "<td nowrap align=right><font size=2 color='" + color + "'><b>" + txt.to_s + "</b></font></td>"
end

def textbc_col(txt, comment)
   str = "<td nowrap><b>" + txt.to_s + "</b> <font size=2><i>(" + comment + ")</i></font></td>\n"
end

def textbc_row(txt, comment)
   s = make_row(textbc_col(txt, comment), 0)
end

def fbox_col(name, value, size)
   str = "<td nowrap><input type=file name='" + name.to_s + "' Value='" + value.to_s + "' size=" + size.to_s + "></td>"
end

def fbox_row(name, value, size)
   s = make_row(fbox_col(name, value, size), 0)
end

def tbox_col(name, value, size)
   str = "<td nowrap><input type=text name='" + name + "' Value='" + value + "' size=" + size.to_s + "></td>"
end

def tbox_row(name, value, size)
   s = make_row(tbox_col(name, value, size), 0)
end

def tarea_col(name, rows, cols)
   str = "<td nowrap><textarea name='" + name + "' rows=" + rows.to_s + " cols=" + cols.to_s + "></textarea></td>"
end

def tarea_col_readonly(name, rows, cols, value)
   str = "<td nowrap><textarea readonly name='" + name + "' rows=" + rows.to_s + " cols=" + cols.to_s + ">" + value + "</textarea></td>"
end

def tarea_row(name, rows, cols)
   s = make_row(tarea_col(name, rows, cols), 0)
end

def combbox_col(name, valarrstr)
  valarr = valarrstr.split("_")
  len = valarr.length
  
  
  s = "<td nowrap>"  
  s = s + "<select name='" + name + "'>"
  i = 1
  for val in valarr
     s = s + "<option value='" + i.to_s + "'>" + val.to_s + "</option>"
     i = i + 1
  end
  s = s + "</select>"
  s = s + "</td>"
  s
end

def combbox_row(name, valarrstr)
   s = make_row(combbox_col(name, valarrstr), 0)
end

def cbox_col(name, value)
   str = "<td nowrap><input type=checkbox name='" + name + "' Value='" + value + "'></td>"
end

def cbox_row(name, value)
   s = make_row(cbox_col(name, value), 0)
end

def cboxchked_col(name, value)
   str = "<td nowrap><input type=checkbox name='" + name + "' Value='" + value + "' checked='yes'></td>"
end

def cboxchked_row(name, value)
   s = make_row(cboxchked_col(name, value), 0)
end

def rbox_col(name, value)
   str = "<td nowrap><input type=radio name='" + name + "' Value='" + value + "'></td>"
end

def rboxchked_col(name, value)
   str = "<td nowrap><input type=radio name='" + name + "' Value='" + value + "' checked='yes'></td>"
end

def rbox_row(name, value)
   s = make_row(rbox_col(name, value), 0)
end

def rboxchked_row(name, value)
   s = make_row(rboxchked_col(name, value), 0)
end

## ================ basic function ================================
def submit_button(txt)
   str = "<input type=submit value='" + txt + "'>"
end

def make_row(col, bgcolor)
   bgclr = get_bgcolor(bgcolor)
   row = "<tr bgcolor=" + bgclr + ">" + col + "</tr>"
   row
end

## ================ color function ================================
def show_color_label(colortype)
   colorarr = colortype.split("_")
   ctype = colorarr[0]
   cutoff = colorarr[1]
   s = ""
   if (ctype == "1")
      s = s + "<font size=2, color=\"blue\">blue>=0</font>, "
      s = s + "<font size=2, color=\"red\">red<0</font>, " 
      s = s + "<font size=2, color=\"gray\">gray=bad well</font>, "
      s = s + "<font size=2, color=\"green\">green=control well</font>"
   elsif (ctype == "2")
      s = s + "<font size=2, color=\"blue\">|blue|>=cutoff</font>, "
      s = s + "<font size=2, color=\"red\">|red| < cutoff</font>, " 
      s = s + "<font size=2, color=\"gray\">gray=bad well</font>, "
      s = s + "<font size=2, color=\"green\">green=control well</font>"
   end
   s
end

def get_color(val, colortype)
   colorarr = colortype.split("_")
   ctype = colorarr[0]
   cutoff = colorarr[1].to_f
         
   if (ctype == "0")
      clr = "black"
   else
      if ((val == "pos") || (val == "neg"))
         clr = "green"
      elsif (val == "bad")
         clr = "gray"
      elsif ((val.to_f >= cutoff) || (val.to_f <= -cutoff))
         clr = "blue"
      elsif (val.to_f.abs < cutoff)
         clr = "red"
      else
         clr = "black"
      end
   end
   clr
end

def get_bgcolor(bgcolor)
   if (bgcolor == 0)
      bgclr = ""
   elsif (bgcolor == 1)
      bgclr = "\"#CCCCCC\""
   else
      bgclr = "\"#CCCCFF\""
   end
   bgclr
end


## ================ show element value function ================================
def show_text(text)
   s =  "<b>" + text + "</b><br>"
   s
end

def show_text_s2(text)
   s =  "<b><font size=2>" + text + "</font></b><br>"
   s
end

def show_cutoff(cutoff)
   s =  "<b>Cutoff = <font color=\"blue\">" + cutoff.to_s + "</font></b><br><br>"
   s
end

def show_log(log)
   str = "<hr width=40%, align='left'>"
   str = str + "<b>Log:</b> <br>"
   str = str + log
   str = str + "<hr width=40%, align='left'><br>"
end

def show_aname(aname)
   s = show_text("Experiment = " + aname.to_s)
   s
end

def show_rid(rid)
   s = show_text("Replicate = " + rid.to_s)
   s
end

def show_pname(pname)
   s = show_text_s2("Plate = " + pname.to_s)
   s
end

def show_error(text)
   s =  "<b><font color='red'>" + text + "</font></b><br><br>"
   s
end

def show_page_head(txt, userid)
   str = "<h2>" + txt + "</h2>" 
   str = str + "<b>User: " + userid + "</b>"
   str = str + "<hr width=100%, align='left'>"
end

def show_project_head(txt, userid)
   str = "<table>"
   str = str + text_row("<h2>" + txt + "</h2>")
   str = str + "<tr>"
   str = str +   textb_col("User: " + userid)
   str = str +   text_col("&nbsp;&nbsp;&nbsp;")
   if ($genv == "development")
      str = str + textb_col("<a href='/upload/logoff'>Logoff</a>")
   else
      str = str + textb_col("<a href='/screen/upload/logoff'>Logoff</a>")
   end
   str = str + "</tr>"
   str = str + "</table>"
   str = str + "<hr width=100%, align='left'>"
end

def show_project_foot()
   str = "<table><tr>"
   if ($genv == "development")
      str = str + textb_col("<a href='/upload/about'>About</a>")
   else
      str = str + textb_col("<a href='/screen/upload/about'>About</a>")
   end
   str = str + text_col("&nbsp;&nbsp;&nbsp;")
   if ($genv == "development")
      str = str + textb_col("<a href='/upload/suggestion'>Suggestion</a>")
   else
      str = str + textb_col("<a href='/screen/upload/suggestion'>Suggestion</a>")
   end
   str = str + text_col("&nbsp;&nbsp;&nbsp;")
   str = str + textb_col("<a href=http://bioinf.itmat.upenn.edu/>Contact us</a>")
   str = str + "</tr></table>"
end

## ================ show depends on func function ================================
def show_check_box(func, ass)
   funcgrp = @@alib.get_func_group(func)
   aid = ass.assay_id.to_s
   if (func == "qualctrl") 
      #s = rbox_col("rbox", aid) 
      s = cboxchked_col("cbox_"+aid, "1")
   elsif (func == "delete") 
      s = cbox_col("cbox_"+aid, "1") 
   elsif (func == "share")
      if (ass.share == 1)
         s = cboxchked_col("cbox_"+aid, "1") 
      else
         s = cbox_col("cbox_"+aid, "1") 
      end
   elsif (funcgrp == 3)
      s = cboxchked_col("cbox_"+aid, "1")
   else 
      s = cboxchked_col("cbox_"+aid, "1") 
   end 
end


end   #class end