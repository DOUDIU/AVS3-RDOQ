
f1 = open(".././result/pq/pq_fpga_coeff/pq_fpga_16x16.txt","r")
f2 = open(".././result/pq/pq_hpm_coeff/pq_hpm_16x16.txt","r")
txt1 = f1.read()
txt2 = f2.read()
if txt1 == txt2:
    print("pq 16x16 : Right!")
else:
    print("pq 16x16 : False!")

f1 = open(".././result/ocd/fpga_prevel/fpga_prevel_16x16.txt","r")
f2 = open(".././result/ocd/hpm_prevel/hpm_prevel_16x16.txt","r")
txt1 = f1.read()
txt2 = f2.read()
if txt1 == txt2:
    print("prevel 16x16 : Right!")
else:
    print("prevel 16x16 : False!")

f1 = open(".././result/ocd/fpga_run/fpga_run_16x16.txt","r")
f2 = open(".././result/ocd/hpm_run/hpm_run_16x16.txt","r")
txt1 = f1.read()
txt2 = f2.read()
if txt1 == txt2:
    print("run 16x16 : Right!")
else:
    print("run 16x16 : False!")

# f1 = open(".././result/ocd/fpga_level_opt/fpga_level_opt_16x16.txt","r")
# f2 = open(".././result/ocd/hpm_level_opt/hpm_level_opt_16x16.txt","r")
# txt1 = f1.read()
# txt2 = f2.read()
# if txt1 == txt2:
#     print("level_opt 16x16 : Right!")
# else:
#     print("level_opt 16x16 : False!")


# f1 = open(".././result/ocd/fpga_uncoded_cost/fpga_uncoded_cost_16x16.txt","r")
# f2 = open(".././result/ocd/hpm_uncoded_cost/hpm_uncoded_cost_16x16.txt","r")
# txt1 = f1.read()
# txt2 = f2.read()
# if txt1 == txt2:
#     print("uncoded_cost 16x16 : Right!")
# else:
#     print("uncoded_cost 16x16 : False!")

# f1 = open(".././result/ocd/fpga_coded_cost/fpga_coded_cost_16x16.txt","r")
# f2 = open(".././result/ocd/hpm_coded_cost/hpm_coded_cost_16x16.txt","r")
# txt1 = f1.read()
# txt2 = f2.read()
# if txt1 == txt2:
#     print("coded_cost 16x16 : Right!")
# else:
#     print("coded_cost 16x16 : False!")

    
# f1 = open(".././result/ocd/fpga_dst_coef/fpga_dst_coef_16x16.txt","r")
# f2 = open(".././result/ocd/hpm_dst_coef/hpm_dst_coef_16x16.txt","r")
# txt1 = f1.read()
# txt2 = f2.read()
# if txt1 == txt2:
#     print("dst_coef 16x16 : Right!")
# else:
#     print("dst_coef 16x16 : False!")





# f1 = open(".././result/ocd/fpga_level_opt/fpga_level_opt_16x16.txt","r")
# f2 = open(".././result/ocd/hpm_level_opt/hpm_level_opt_16x16.txt","r")
# txt1 = f1.read()
# txt2 = f2.read()
# if txt1 == txt2:
#     print("level_opt 16x16 : Right!")
# else:
#     print("level_opt 16x16 : False!")