
def fun_16x16_pq():
    #pq
    print("\npq:")
    f0 = open(".././result/pq/pq_fpga_coeff/pq_fpga_16x16_0.txt","r")
    f1 = open(".././result/pq/pq_fpga_coeff/pq_fpga_16x16_1.txt","r")
    f2 = open(".././result/pq/pq_hpm_coeff/pq_hpm_16x16.txt","r")
    txt0 = f0.read()
    txt1 = f1.read()
    txt2 = f2.read()
    if txt0 == txt1 == txt2:
        print("pq 16x16 : Right!")
    else:
        print("pq 16x16 : False!")

def fun_16x16_ocd():
    #ocd
    print("\nocd:")
    f0 = open(".././result/ocd/fpga_prevel/fpga_prevel_16x16_0.txt","r")
    f1 = open(".././result/ocd/fpga_prevel/fpga_prevel_16x16_1.txt","r")
    f2 = open(".././result/ocd/hpm_prevel/hpm_prevel_16x16.txt","r")
    txt0 = f0.read()
    txt1 = f1.read()
    txt2 = f2.read()
    if txt0 == txt1 == txt2:
        print("prevel 16x16 : Right!")
    else:
        print("prevel 16x16 : False!")

    f0 = open(".././result/ocd/fpga_run/fpga_run_16x16_0.txt","r")
    f1 = open(".././result/ocd/fpga_run/fpga_run_16x16_1.txt","r")
    f2 = open(".././result/ocd/hpm_run/hpm_run_16x16.txt","r")
    txt0 = f0.read()
    txt1 = f1.read()
    txt2 = f2.read()
    if txt0 == txt1 == txt2:
        print("run 16x16 : Right!")
    else:
        print("run 16x16 : False!")

    f0 = open(".././result/ocd/fpga_level_opt/fpga_level_opt_16x16_0.txt","r")
    f1 = open(".././result/ocd/fpga_level_opt/fpga_level_opt_16x16_1.txt","r")
    f2 = open(".././result/ocd/hpm_level_opt/hpm_level_opt_16x16.txt","r")
    txt0 = f0.read()
    txt1 = f1.read()
    txt2 = f2.read()
    if txt0 == txt1 == txt2:
        print("level_opt 16x16 : Right!")
    else:
        print("level_opt 16x16 : False!")


    f0 = open(".././result/ocd/fpga_uncoded_cost/fpga_uncoded_cost_16x16_0.txt","r")
    f1 = open(".././result/ocd/fpga_uncoded_cost/fpga_uncoded_cost_16x16_1.txt","r")
    f2 = open(".././result/ocd/hpm_uncoded_cost/hpm_uncoded_cost_16x16.txt","r")
    txt0 = f0.read()
    txt1 = f1.read()
    txt2 = f2.read()
    if txt0 == txt1 == txt2:
        print("uncoded_cost 16x16 : Right!")
    else:
        print("uncoded_cost 16x16 : False!")

    f0 = open(".././result/ocd/fpga_coded_cost/fpga_coded_cost_16x16_0.txt","r")
    f1 = open(".././result/ocd/fpga_coded_cost/fpga_coded_cost_16x16_1.txt","r")
    f2 = open(".././result/ocd/hpm_coded_cost/hpm_coded_cost_16x16.txt","r")
    txt0 = f0.read()
    txt1 = f1.read()
    txt2 = f2.read()
    if txt0 == txt1 == txt2:
        print("coded_cost 16x16 : Right!")
    else:
        print("coded_cost 16x16 : False!")

    f0 = open(".././result/ocd/fpga_level_opt/fpga_level_opt_16x16_0.txt","r")
    f1 = open(".././result/ocd/fpga_level_opt/fpga_level_opt_16x16_1.txt","r")
    f2 = open(".././result/ocd/hpm_level_opt/hpm_level_opt_16x16.txt","r")
    txt0 = f0.read()
    txt1 = f1.read()
    txt2 = f2.read()
    if txt0 == txt1 == txt2:
        print("level_opt 16x16 : Right!")
    else:
        print("level_opt 16x16 : False!")

        
    f0 = open(".././result/ocd/fpga_base_cost_buffer/fpga_base_cost_buffer_16x16_0.txt","r")
    f1 = open(".././result/ocd/fpga_base_cost_buffer/fpga_base_cost_buffer_16x16_1.txt","r")
    f2 = open(".././result/ocd/hpm_base_cost_buffer/hpm_base_cost_buffer_16x16.txt","r")
    txt0 = f0.read()
    txt1 = f1.read()
    txt2 = f2.read()
    if txt0 == txt1 == txt2:
        print("base_cost_buffer 16x16 : Right!")
    else:
        print("base_cost_buffer 16x16 : False!")

def fun_16x16_lnpq():
    #lnpd
    print("\nlnpd:")
    f0 = open(".././result/lnpd/fpga_rdoq_last_x/fpga_rdoq_last_x_16x16_0.txt","r")
    f1 = open(".././result/lnpd/fpga_rdoq_last_x/fpga_rdoq_last_x_16x16_1.txt","r")
    f2 = open(".././result/lnpd/hpm_rdoq_last_x/hpm_rdoq_last_x_16x16.txt","r")
    txt0 = f0.read()
    txt1 = f1.read()
    txt2 = f2.read()
    if txt0 == txt1 == txt2:
        print("rdoq_last_x 16x16 : Right!")
    else:
        print("rdoq_last_x 16x16 : False!")

    f0 = open(".././result/lnpd/fpga_rdoq_last_y/fpga_rdoq_last_y_16x16_0.txt","r")
    f1 = open(".././result/lnpd/fpga_rdoq_last_y/fpga_rdoq_last_y_16x16_1.txt","r")
    f2 = open(".././result/lnpd/hpm_rdoq_last_y/hpm_rdoq_last_y_16x16.txt","r")
    txt0 = f0.read()
    txt1 = f1.read()
    txt2 = f2.read()
    if txt0 == txt1 == txt2:
        print("rdoq_last_y 16x16 : Right!")
    else:
        print("rdoq_last_y 16x16 : False!")

    f0 = open(".././result/lnpd/fpga_endPosCost/fpga_endPosCost_16x16_0.txt","r")
    f1 = open(".././result/lnpd/fpga_endPosCost/fpga_endPosCost_16x16_1.txt","r")
    f2 = open(".././result/lnpd/hpm_endPosCost/hpm_endPosCost_16x16.txt","r")
    txt0 = f0.read()
    txt1 = f1.read()
    txt2 = f2.read()
    if txt0 == txt1 == txt2:
        print("endPosCost 16x16 : Right!")
    else:
        print("endPosCost 16x16 : False!")


    f0 = open(".././result/lnpd/fpga_rdoqD64LastOne/fpga_rdoqD64LastOne_16x16_0.txt","r")
    f1 = open(".././result/lnpd/fpga_rdoqD64LastOne/fpga_rdoqD64LastOne_16x16_1.txt","r")
    f2 = open(".././result/lnpd/hpm_rdoqD64LastOne/hpm_rdoqD64LastOne_16x16.txt","r")
    txt0 = f0.read()
    txt1 = f1.read()
    txt2 = f2.read()
    if txt0 == txt1 == txt2:
        print("rdoqD64LastOne 16x16 : Right!")
    else:
        print("rdoqD64LastOne 16x16 : False!")

    f0 = open(".././result/lnpd/fpga_rdoqD64LastZero/fpga_rdoqD64LastZero_16x16_0.txt","r")
    f1 = open(".././result/lnpd/fpga_rdoqD64LastZero/fpga_rdoqD64LastZero_16x16_1.txt","r")
    f2 = open(".././result/lnpd/hpm_rdoqD64LastZero/hpm_rdoqD64LastZero_16x16.txt","r")
    txt0 = f0.read()
    txt1 = f1.read()
    txt2 = f2.read()
    if txt0 == txt1 == txt2:
        print("rdoqD64LastZero 16x16 : Right!")
    else:
        print("rdoqD64LastZero 16x16 : False!")

    f0 = open(".././result/lnpd/fpga_tempCost/fpga_tempCost_16x16_0.txt","r")
    f1 = open(".././result/lnpd/fpga_tempCost/fpga_tempCost_16x16_1.txt","r")
    f2 = open(".././result/lnpd/hpm_tempCost/hpm_tempCost_16x16.txt","r")
    txt0 = f0.read()
    txt1 = f1.read()
    txt2 = f2.read()
    if txt0 == txt1 == txt2:
        print("tempCost 16x16 : Right!")
    else:
        print("tempCost 16x16 : False!")


def fun_32x32_pq():
    #pq
    print("\npq:")
    f0 = open(".././result/pq/pq_fpga_coeff/pq_fpga_32x32.txt","r")
    f1 = open(".././result/pq/pq_hpm_coeff/pq_hpm_32x32.txt","r")
    txt0 = f0.read()
    txt1 = f1.read()
    if txt0 == txt1:
        print("pq 32x32 : Right!")
    else:
        print("pq 32x32 : False!")

def fun_32x32_ocd():
    #ocd
    print("\nocd:")
    f1 = open(".././result/ocd/fpga_prevel/fpga_prevel_32x32.txt","r")
    f2 = open(".././result/ocd/hpm_prevel/hpm_prevel_32x32.txt","r")
    txt1 = f1.read()
    txt2 = f2.read()
    if txt1 == txt2:
        print("prevel 32x32 : Right!")
    else:
        print("prevel 32x32 : False!")

    f1 = open(".././result/ocd/fpga_run/fpga_run_32x32.txt","r")
    f2 = open(".././result/ocd/hpm_run/hpm_run_32x32.txt","r")
    txt1 = f1.read()
    txt2 = f2.read()
    if txt1 == txt2:
        print("run 32x32 : Right!")
    else:
        print("run 32x32 : False!")

    f1 = open(".././result/ocd/fpga_level_opt/fpga_level_opt_32x32.txt","r")
    f2 = open(".././result/ocd/hpm_level_opt/hpm_level_opt_32x32.txt","r")
    txt1 = f1.read()
    txt2 = f2.read()
    if txt1 == txt2:
        print("level_opt 32x32 : Right!")
    else:
        print("level_opt 32x32 : False!")


    f1 = open(".././result/ocd/fpga_uncoded_cost/fpga_uncoded_cost_32x32.txt","r")
    f2 = open(".././result/ocd/hpm_uncoded_cost/hpm_uncoded_cost_32x32.txt","r")
    txt1 = f1.read()
    txt2 = f2.read()
    if txt1 == txt2:
        print("uncoded_cost 32x32 : Right!")
    else:
        print("uncoded_cost 32x32 : False!")

    f1 = open(".././result/ocd/fpga_coded_cost/fpga_coded_cost_32x32.txt","r")
    f2 = open(".././result/ocd/hpm_coded_cost/hpm_coded_cost_32x32.txt","r")
    txt1 = f1.read()
    txt2 = f2.read()
    if txt1 == txt2:
        print("coded_cost 32x32 : Right!")
    else:
        print("coded_cost 32x32 : False!")


    f1 = open(".././result/ocd/fpga_level_opt/fpga_level_opt_32x32.txt","r")
    f2 = open(".././result/ocd/hpm_level_opt/hpm_level_opt_32x32.txt","r")
    txt1 = f1.read()
    txt2 = f2.read()
    if txt1 == txt2:
        print("level_opt 32x32 : Right!")
    else:
        print("level_opt 32x32 : False!")

        
    f1 = open(".././result/ocd/fpga_base_cost_buffer/fpga_base_cost_buffer_32x32.txt","r")
    f2 = open(".././result/ocd/hpm_base_cost_buffer/hpm_base_cost_buffer_32x32.txt","r")
    txt1 = f1.read()
    txt2 = f2.read()
    if txt1 == txt2:
        print("base_cost_buffer 32x32 : Right!")
    else:
        print("base_cost_buffer 32x32 : False!")

def fun_32x32_lnpd():
    #lnpd
    print("\nlnpd:")
    f1 = open(".././result/lnpd/fpga_rdoq_last_x/fpga_rdoq_last_x_32x32.txt","r")
    f2 = open(".././result/lnpd/hpm_rdoq_last_x/hpm_rdoq_last_x_32x32.txt","r")
    txt1 = f1.read()
    txt2 = f2.read()
    if txt1 == txt2:
        print("rdoq_last_x 32x32 : Right!")
    else:
        print("rdoq_last_x 32x32 : False!")



    f1 = open(".././result/lnpd/fpga_rdoq_last_y/fpga_rdoq_last_y_32x32.txt","r")
    f2 = open(".././result/lnpd/hpm_rdoq_last_y/hpm_rdoq_last_y_32x32.txt","r")
    txt1 = f1.read()
    txt2 = f2.read()
    if txt1 == txt2:
        print("rdoq_last_y 32x32 : Right!")
    else:
        print("rdoq_last_y 32x32 : False!")


    f1 = open(".././result/lnpd/fpga_endPosCost/fpga_endPosCost_32x32.txt","r")
    f2 = open(".././result/lnpd/hpm_endPosCost/hpm_endPosCost_32x32.txt","r")
    txt1 = f1.read()
    txt2 = f2.read()
    if txt1 == txt2:
        print("endPosCost 32x32 : Right!")
    else:
        print("endPosCost 32x32 : False!")


    f1 = open(".././result/lnpd/fpga_rdoqD64LastOne/fpga_rdoqD64LastOne_32x32.txt","r")
    f2 = open(".././result/lnpd/hpm_rdoqD64LastOne/hpm_rdoqD64LastOne_32x32.txt","r")
    txt1 = f1.read()
    txt2 = f2.read()
    if txt1 == txt2:
        print("rdoqD64LastOne 32x32 : Right!")
    else:
        print("rdoqD64LastOne 32x32 : False!")


    f1 = open(".././result/lnpd/fpga_rdoqD64LastZero/fpga_rdoqD64LastZero_32x32.txt","r")
    f2 = open(".././result/lnpd/hpm_rdoqD64LastZero/hpm_rdoqD64LastZero_32x32.txt","r")
    txt1 = f1.read()
    txt2 = f2.read()
    if txt1 == txt2:
        print("rdoqD64LastZero 32x32 : Right!")
    else:
        print("rdoqD64LastZero 32x32 : False!")


    f1 = open(".././result/lnpd/fpga_tempCost/fpga_tempCost_32x32.txt","r")
    f2 = open(".././result/lnpd/hpm_tempCost/hpm_tempCost_32x32.txt","r")
    txt1 = f1.read()
    txt2 = f2.read()
    if txt1 == txt2:
        print("tempCost 32x32 : Right!")
    else:
        print("tempCost 32x32 : False!")


def fun_8x8_pq():
    #pq
    print("\npq:")
    f0 = open(".././result/pq/pq_fpga_coeff/pq_fpga_8x8_0.txt","r")
    f1 = open(".././result/pq/pq_fpga_coeff/pq_fpga_8x8_1.txt","r")
    f2 = open(".././result/pq/pq_fpga_coeff/pq_fpga_8x8_2.txt","r")
    f3 = open(".././result/pq/pq_fpga_coeff/pq_fpga_8x8_3.txt","r")
    f4 = open(".././result/pq/pq_hpm_coeff/pq_hpm_8x8.txt","r")
    txt0 = f0.read()
    txt1 = f1.read()
    txt2 = f2.read()
    txt3 = f3.read()
    txt4 = f4.read()
    if txt0 == txt1 == txt2 == txt3 == txt4:
        print("pq 8x8 : Right!")
    else:
        print("pq 8x8 : False!")

def fun_8x8_ocd():
    #ocd
    print("\nocd:")
    f0 = open(".././result/ocd/fpga_prevel/fpga_prevel_8x8_0.txt","r")
    f1 = open(".././result/ocd/fpga_prevel/fpga_prevel_8x8_1.txt","r")
    f2 = open(".././result/ocd/fpga_prevel/fpga_prevel_8x8_2.txt","r")
    f3 = open(".././result/ocd/fpga_prevel/fpga_prevel_8x8_3.txt","r")
    f4 = open(".././result/ocd/hpm_prevel/hpm_prevel_8x8.txt","r")
    txt0 = f0.read()
    txt1 = f1.read()
    txt2 = f2.read()
    txt3 = f3.read()
    txt4 = f4.read()
    if txt0 == txt1 == txt2 == txt3 == txt4:
        print("prevel 8x8 : Right!")
    else:
        print("prevel 8x8 : False!")

    f0 = open(".././result/ocd/fpga_run/fpga_run_8x8_0.txt","r")
    f1 = open(".././result/ocd/fpga_run/fpga_run_8x8_1.txt","r")
    f2 = open(".././result/ocd/fpga_run/fpga_run_8x8_2.txt","r")
    f3 = open(".././result/ocd/fpga_run/fpga_run_8x8_3.txt","r")
    f4 = open(".././result/ocd/hpm_run/hpm_run_8x8.txt","r")
    txt0 = f0.read()
    txt1 = f1.read()
    txt2 = f2.read()
    txt3 = f3.read()
    txt4 = f4.read()
    if txt0 == txt1 == txt2 == txt3 == txt4:
        print("run 8x8 : Right!")
    else:
        print("run 8x8 : False!")

    f0 = open(".././result/ocd/fpga_level_opt/fpga_level_opt_8x8_0.txt","r")
    f1 = open(".././result/ocd/fpga_level_opt/fpga_level_opt_8x8_1.txt","r")
    f2 = open(".././result/ocd/fpga_level_opt/fpga_level_opt_8x8_2.txt","r")
    f3 = open(".././result/ocd/fpga_level_opt/fpga_level_opt_8x8_3.txt","r")
    f4 = open(".././result/ocd/hpm_level_opt/hpm_level_opt_8x8.txt","r")
    txt0 = f0.read()
    txt1 = f1.read()
    txt2 = f2.read()
    txt3 = f3.read()
    txt4 = f4.read()
    if txt0 == txt1 == txt2 == txt3 == txt4:
        print("level_opt 8x8 : Right!")
    else:
        print("level_opt 8x8 : False!")


    f0 = open(".././result/ocd/fpga_uncoded_cost/fpga_uncoded_cost_8x8_0.txt","r")
    f1 = open(".././result/ocd/fpga_uncoded_cost/fpga_uncoded_cost_8x8_1.txt","r")
    f2 = open(".././result/ocd/fpga_uncoded_cost/fpga_uncoded_cost_8x8_2.txt","r")
    f3 = open(".././result/ocd/fpga_uncoded_cost/fpga_uncoded_cost_8x8_3.txt","r")
    f4 = open(".././result/ocd/hpm_uncoded_cost/hpm_uncoded_cost_8x8.txt","r")
    txt0 = f0.read()
    txt1 = f1.read()
    txt2 = f2.read()
    txt3 = f3.read()
    txt4 = f4.read()
    if txt0 == txt1 == txt2 == txt3 == txt4:
        print("uncoded_cost 8x8 : Right!")
    else:
        print("uncoded_cost 8x8 : False!")

    f0 = open(".././result/ocd/fpga_coded_cost/fpga_coded_cost_8x8_0.txt","r")
    f1 = open(".././result/ocd/fpga_coded_cost/fpga_coded_cost_8x8_1.txt","r")
    f2 = open(".././result/ocd/fpga_coded_cost/fpga_coded_cost_8x8_2.txt","r")
    f3 = open(".././result/ocd/fpga_coded_cost/fpga_coded_cost_8x8_3.txt","r")
    f4 = open(".././result/ocd/hpm_coded_cost/hpm_coded_cost_8x8.txt","r")
    txt0 = f0.read()
    txt1 = f1.read()
    txt2 = f2.read()
    txt3 = f3.read()
    txt4 = f4.read()
    if txt0 == txt1 == txt2 == txt3 == txt4:
        print("coded_cost 8x8 : Right!")
    else:
        print("coded_cost 8x8 : False!")


    f0 = open(".././result/ocd/fpga_level_opt/fpga_level_opt_8x8_0.txt","r")
    f1 = open(".././result/ocd/fpga_level_opt/fpga_level_opt_8x8_1.txt","r")
    f2 = open(".././result/ocd/fpga_level_opt/fpga_level_opt_8x8_2.txt","r")
    f3 = open(".././result/ocd/fpga_level_opt/fpga_level_opt_8x8_3.txt","r")
    f4 = open(".././result/ocd/hpm_level_opt/hpm_level_opt_8x8.txt","r")
    txt0 = f0.read()
    txt1 = f1.read()
    txt2 = f2.read()
    txt3 = f3.read()
    txt4 = f4.read()
    if txt0 == txt1 == txt2 == txt3 == txt4:
        print("level_opt 8x8 : Right!")
    else:
        print("level_opt 8x8 : False!")

        
    f0 = open(".././result/ocd/fpga_base_cost_buffer/fpga_base_cost_buffer_8x8_0.txt","r")
    f1 = open(".././result/ocd/fpga_base_cost_buffer/fpga_base_cost_buffer_8x8_1.txt","r")
    f2 = open(".././result/ocd/fpga_base_cost_buffer/fpga_base_cost_buffer_8x8_2.txt","r")
    f3 = open(".././result/ocd/fpga_base_cost_buffer/fpga_base_cost_buffer_8x8_3.txt","r")
    f4 = open(".././result/ocd/hpm_base_cost_buffer/hpm_base_cost_buffer_8x8.txt","r")
    txt0 = f0.read()
    txt1 = f1.read()
    txt2 = f2.read()
    txt3 = f3.read()
    txt4 = f4.read()
    if txt0 == txt1 == txt2 == txt3 == txt4:
        print("base_cost_buffer 8x8 : Right!")
    else:
        print("base_cost_buffer 8x8 : False!")

def fun_8x8_lnpd():
    #lnpd
    print("\nlnpd:")
    f0 = open(".././result/lnpd/fpga_rdoq_last_x/fpga_rdoq_last_x_8x8_0.txt","r")
    f1 = open(".././result/lnpd/fpga_rdoq_last_x/fpga_rdoq_last_x_8x8_1.txt","r")
    f2 = open(".././result/lnpd/fpga_rdoq_last_x/fpga_rdoq_last_x_8x8_2.txt","r")
    f3 = open(".././result/lnpd/fpga_rdoq_last_x/fpga_rdoq_last_x_8x8_3.txt","r")
    f4 = open(".././result/lnpd/hpm_rdoq_last_x/hpm_rdoq_last_x_8x8.txt","r")
    txt0 = f0.read()
    txt1 = f1.read()
    txt2 = f2.read()
    txt3 = f3.read()
    txt4 = f4.read()
    if txt0 == txt1 == txt2 == txt3 == txt4:
        print("rdoq_last_x 8x8 : Right!")
    else:
        print("rdoq_last_x 8x8 : False!")

    f0 = open(".././result/lnpd/fpga_rdoq_last_y/fpga_rdoq_last_y_8x8_0.txt","r")
    f1 = open(".././result/lnpd/fpga_rdoq_last_y/fpga_rdoq_last_y_8x8_1.txt","r")
    f2 = open(".././result/lnpd/fpga_rdoq_last_y/fpga_rdoq_last_y_8x8_2.txt","r")
    f3 = open(".././result/lnpd/fpga_rdoq_last_y/fpga_rdoq_last_y_8x8_3.txt","r")
    f4 = open(".././result/lnpd/hpm_rdoq_last_y/hpm_rdoq_last_y_8x8.txt","r")
    txt0 = f0.read()
    txt1 = f1.read()
    txt2 = f2.read()
    txt3 = f3.read()
    txt4 = f4.read()
    if txt0 == txt1 == txt2 == txt3 == txt4:
        print("rdoq_last_y 8x8 : Right!")
    else:
        print("rdoq_last_y 8x8 : False!")


    f0 = open(".././result/lnpd/fpga_endPosCost/fpga_endPosCost_8x8_0.txt","r")
    f1 = open(".././result/lnpd/fpga_endPosCost/fpga_endPosCost_8x8_1.txt","r")
    f2 = open(".././result/lnpd/fpga_endPosCost/fpga_endPosCost_8x8_2.txt","r")
    f3 = open(".././result/lnpd/fpga_endPosCost/fpga_endPosCost_8x8_3.txt","r")
    f4 = open(".././result/lnpd/hpm_endPosCost/hpm_endPosCost_8x8.txt","r")
    txt0 = f0.read()
    txt1 = f1.read()
    txt2 = f2.read()
    txt3 = f3.read()
    txt4 = f4.read()
    if txt0 == txt1 == txt2 == txt3 == txt4:
        print("endPosCost 8x8 : Right!")
    else:
        print("endPosCost 8x8 : False!")


    f0 = open(".././result/lnpd/fpga_rdoqD64LastOne/fpga_rdoqD64LastOne_8x8_0.txt","r")
    f1 = open(".././result/lnpd/fpga_rdoqD64LastOne/fpga_rdoqD64LastOne_8x8_1.txt","r")
    f2 = open(".././result/lnpd/fpga_rdoqD64LastOne/fpga_rdoqD64LastOne_8x8_2.txt","r")
    f3 = open(".././result/lnpd/fpga_rdoqD64LastOne/fpga_rdoqD64LastOne_8x8_3.txt","r")
    f4 = open(".././result/lnpd/hpm_rdoqD64LastOne/hpm_rdoqD64LastOne_8x8.txt","r")
    txt0 = f0.read()
    txt1 = f1.read()
    txt2 = f2.read()
    txt3 = f3.read()
    txt4 = f4.read()
    if txt0 == txt1 == txt2 == txt3 == txt4:
        print("rdoqD64LastOne 8x8 : Right!")
    else:
        print("rdoqD64LastOne 8x8 : False!")


    f0 = open(".././result/lnpd/fpga_rdoqD64LastZero/fpga_rdoqD64LastZero_8x8_0.txt","r")
    f1 = open(".././result/lnpd/fpga_rdoqD64LastZero/fpga_rdoqD64LastZero_8x8_1.txt","r")
    f2 = open(".././result/lnpd/fpga_rdoqD64LastZero/fpga_rdoqD64LastZero_8x8_2.txt","r")
    f3 = open(".././result/lnpd/fpga_rdoqD64LastZero/fpga_rdoqD64LastZero_8x8_3.txt","r")
    f4 = open(".././result/lnpd/hpm_rdoqD64LastZero/hpm_rdoqD64LastZero_8x8.txt","r")
    txt0 = f0.read()
    txt1 = f1.read()
    txt2 = f2.read()
    txt3 = f3.read()
    txt4 = f4.read()
    if txt0 == txt1 == txt2 == txt3 == txt4:
        print("rdoqD64LastZero 8x8 : Right!")
    else:
        print("rdoqD64LastZero 8x8 : False!")


    f0 = open(".././result/lnpd/fpga_tempCost/fpga_tempCost_8x8_0.txt","r")
    f1 = open(".././result/lnpd/fpga_tempCost/fpga_tempCost_8x8_1.txt","r")
    f2 = open(".././result/lnpd/fpga_tempCost/fpga_tempCost_8x8_2.txt","r")
    f3 = open(".././result/lnpd/fpga_tempCost/fpga_tempCost_8x8_3.txt","r")
    f4 = open(".././result/lnpd/hpm_tempCost/hpm_tempCost_8x8.txt","r")
    txt0 = f0.read()
    txt1 = f1.read()
    txt2 = f2.read()
    txt3 = f3.read()
    txt4 = f4.read()
    if txt0 == txt1 == txt2 == txt3 == txt4:
        print("tempCost 8x8 : Right!")
    else:
        print("tempCost 8x8 : False!")


def fun_4x4_pq():
    #pq
    print("\npq:")
    f0 = open(".././result/pq/pq_fpga_coeff/pq_fpga_4x4_0.txt","r")
    f1 = open(".././result/pq/pq_fpga_coeff/pq_fpga_4x4_1.txt","r")
    f2 = open(".././result/pq/pq_fpga_coeff/pq_fpga_4x4_2.txt","r")
    f3 = open(".././result/pq/pq_fpga_coeff/pq_fpga_4x4_3.txt","r")
    f4 = open(".././result/pq/pq_fpga_coeff/pq_fpga_4x4_4.txt","r")
    f5 = open(".././result/pq/pq_fpga_coeff/pq_fpga_4x4_5.txt","r")
    f6 = open(".././result/pq/pq_fpga_coeff/pq_fpga_4x4_6.txt","r")
    f7 = open(".././result/pq/pq_fpga_coeff/pq_fpga_4x4_7.txt","r")
    f8 = open(".././result/pq/pq_hpm_coeff/pq_hpm_4x4.txt","r")
    txt0 = f0.read()
    txt1 = f1.read()
    txt2 = f2.read()
    txt3 = f3.read()
    txt4 = f4.read()
    txt5 = f5.read()
    txt6 = f6.read()
    txt7 = f7.read()
    txt8 = f8.read()
    if txt0 == txt1 == txt2 == txt3 == txt4 == txt5 == txt6 == txt7 == txt8:
        print("pq 4x4 : Right!")
    else:
        print("pq 4x4 : False!")

def fun_4x4_ocd():    
    #ocd
    print("\nocd:")
    f0 = open(".././result/ocd/fpga_prevel/fpga_prevel_4x4_0.txt","r")
    f1 = open(".././result/ocd/fpga_prevel/fpga_prevel_4x4_1.txt","r")
    f2 = open(".././result/ocd/fpga_prevel/fpga_prevel_4x4_2.txt","r")
    f3 = open(".././result/ocd/fpga_prevel/fpga_prevel_4x4_3.txt","r")
    f4 = open(".././result/ocd/fpga_prevel/fpga_prevel_4x4_4.txt","r")
    f5 = open(".././result/ocd/fpga_prevel/fpga_prevel_4x4_5.txt","r")
    f6 = open(".././result/ocd/fpga_prevel/fpga_prevel_4x4_6.txt","r")
    f7 = open(".././result/ocd/fpga_prevel/fpga_prevel_4x4_7.txt","r")
    f8 = open(".././result/ocd/hpm_prevel/hpm_prevel_4x4.txt","r")
    txt0 = f0.read()
    txt1 = f1.read()
    txt2 = f2.read()
    txt3 = f3.read()
    txt4 = f4.read()
    txt5 = f5.read()
    txt6 = f6.read()
    txt7 = f7.read()
    txt8 = f8.read()
    if txt0 == txt1 == txt2 == txt3 == txt4 == txt5 == txt6 == txt7 == txt8:
        print("prevel 4x4 : Right!")
    else:
        print("prevel 4x4 : False!")

    f0 = open(".././result/ocd/fpga_run/fpga_run_4x4_0.txt","r")
    f1 = open(".././result/ocd/fpga_run/fpga_run_4x4_1.txt","r")
    f2 = open(".././result/ocd/fpga_run/fpga_run_4x4_2.txt","r")
    f3 = open(".././result/ocd/fpga_run/fpga_run_4x4_3.txt","r")
    f4 = open(".././result/ocd/fpga_run/fpga_run_4x4_4.txt","r")
    f5 = open(".././result/ocd/fpga_run/fpga_run_4x4_5.txt","r")
    f6 = open(".././result/ocd/fpga_run/fpga_run_4x4_6.txt","r")
    f7 = open(".././result/ocd/fpga_run/fpga_run_4x4_7.txt","r")
    f8 = open(".././result/ocd/hpm_run/hpm_run_4x4.txt","r")
    txt0 = f0.read()
    txt1 = f1.read()
    txt2 = f2.read()
    txt3 = f3.read()
    txt4 = f4.read()
    txt5 = f5.read()
    txt6 = f6.read()
    txt7 = f7.read()
    txt8 = f8.read()
    if txt0 == txt1 == txt2 == txt3 == txt4 == txt5 == txt6 == txt7 == txt8:
        print("run 4x4 : Right!")
    else:
        print("run 4x4 : False!")

    f0 = open(".././result/ocd/fpga_level_opt/fpga_level_opt_4x4_0.txt","r")
    f1 = open(".././result/ocd/fpga_level_opt/fpga_level_opt_4x4_1.txt","r")
    f2 = open(".././result/ocd/fpga_level_opt/fpga_level_opt_4x4_2.txt","r")
    f3 = open(".././result/ocd/fpga_level_opt/fpga_level_opt_4x4_3.txt","r")
    f4 = open(".././result/ocd/fpga_level_opt/fpga_level_opt_4x4_4.txt","r")
    f5 = open(".././result/ocd/fpga_level_opt/fpga_level_opt_4x4_5.txt","r")
    f6 = open(".././result/ocd/fpga_level_opt/fpga_level_opt_4x4_6.txt","r")
    f7 = open(".././result/ocd/fpga_level_opt/fpga_level_opt_4x4_7.txt","r")
    f8 = open(".././result/ocd/hpm_level_opt/hpm_level_opt_4x4.txt","r")
    txt0 = f0.read()
    txt1 = f1.read()
    txt2 = f2.read()
    txt3 = f3.read()
    txt4 = f4.read()
    txt5 = f5.read()
    txt6 = f6.read()
    txt7 = f7.read()
    txt8 = f8.read()
    if txt0 == txt1 == txt2 == txt3 == txt4 == txt5 == txt6 == txt7 == txt8:
        print("level_opt 4x4 : Right!")
    else:
        print("level_opt 4x4 : False!")


    f0 = open(".././result/ocd/fpga_uncoded_cost/fpga_uncoded_cost_4x4_0.txt","r")
    f1 = open(".././result/ocd/fpga_uncoded_cost/fpga_uncoded_cost_4x4_1.txt","r")
    f2 = open(".././result/ocd/fpga_uncoded_cost/fpga_uncoded_cost_4x4_2.txt","r")
    f3 = open(".././result/ocd/fpga_uncoded_cost/fpga_uncoded_cost_4x4_3.txt","r")
    f4 = open(".././result/ocd/fpga_uncoded_cost/fpga_uncoded_cost_4x4_4.txt","r")
    f5 = open(".././result/ocd/fpga_uncoded_cost/fpga_uncoded_cost_4x4_5.txt","r")
    f6 = open(".././result/ocd/fpga_uncoded_cost/fpga_uncoded_cost_4x4_6.txt","r")
    f7 = open(".././result/ocd/fpga_uncoded_cost/fpga_uncoded_cost_4x4_7.txt","r")
    f8 = open(".././result/ocd/hpm_uncoded_cost/hpm_uncoded_cost_4x4.txt","r")
    txt0 = f0.read()
    txt1 = f1.read()
    txt2 = f2.read()
    txt3 = f3.read()
    txt4 = f4.read()
    txt5 = f5.read()
    txt6 = f6.read()
    txt7 = f7.read()
    txt8 = f8.read()
    if txt0 == txt1 == txt2 == txt3 == txt4 == txt5 == txt6 == txt7 == txt8:
        print("uncoded_cost 4x4 : Right!")
    else:
        print("uncoded_cost 4x4 : False!")

    f0 = open(".././result/ocd/fpga_coded_cost/fpga_coded_cost_4x4_0.txt","r")
    f1 = open(".././result/ocd/fpga_coded_cost/fpga_coded_cost_4x4_1.txt","r")
    f2 = open(".././result/ocd/fpga_coded_cost/fpga_coded_cost_4x4_2.txt","r")
    f3 = open(".././result/ocd/fpga_coded_cost/fpga_coded_cost_4x4_3.txt","r")
    f4 = open(".././result/ocd/fpga_coded_cost/fpga_coded_cost_4x4_4.txt","r")
    f5 = open(".././result/ocd/fpga_coded_cost/fpga_coded_cost_4x4_5.txt","r")
    f6 = open(".././result/ocd/fpga_coded_cost/fpga_coded_cost_4x4_6.txt","r")
    f7 = open(".././result/ocd/fpga_coded_cost/fpga_coded_cost_4x4_7.txt","r")
    f8 = open(".././result/ocd/hpm_coded_cost/hpm_coded_cost_4x4.txt","r")
    txt0 = f0.read()
    txt1 = f1.read()
    txt2 = f2.read()
    txt3 = f3.read()
    txt4 = f4.read()
    txt5 = f5.read()
    txt6 = f6.read()
    txt7 = f7.read()
    txt8 = f8.read()
    if txt0 == txt1 == txt2 == txt3 == txt4 == txt5 == txt6 == txt7 == txt8:
        print("coded_cost 4x4 : Right!")
    else:
        print("coded_cost 4x4 : False!")


    f0 = open(".././result/ocd/fpga_level_opt/fpga_level_opt_4x4_0.txt","r")
    f1 = open(".././result/ocd/fpga_level_opt/fpga_level_opt_4x4_1.txt","r")
    f2 = open(".././result/ocd/fpga_level_opt/fpga_level_opt_4x4_2.txt","r")
    f3 = open(".././result/ocd/fpga_level_opt/fpga_level_opt_4x4_3.txt","r")
    f4 = open(".././result/ocd/fpga_level_opt/fpga_level_opt_4x4_4.txt","r")
    f5 = open(".././result/ocd/fpga_level_opt/fpga_level_opt_4x4_5.txt","r")
    f6 = open(".././result/ocd/fpga_level_opt/fpga_level_opt_4x4_6.txt","r")
    f7 = open(".././result/ocd/fpga_level_opt/fpga_level_opt_4x4_7.txt","r")
    f8 = open(".././result/ocd/hpm_level_opt/hpm_level_opt_4x4.txt","r")
    txt0 = f0.read()
    txt1 = f1.read()
    txt2 = f2.read()
    txt3 = f3.read()
    txt4 = f4.read()
    txt5 = f5.read()
    txt6 = f6.read()
    txt7 = f7.read()
    txt8 = f8.read()
    if txt0 == txt1 == txt2 == txt3 == txt4 == txt5 == txt6 == txt7 == txt8:
        print("level_opt 4x4 : Right!")
    else:
        print("level_opt 4x4 : False!")

        
    f0 = open(".././result/ocd/fpga_base_cost_buffer/fpga_base_cost_buffer_4x4_0.txt","r")
    f1 = open(".././result/ocd/fpga_base_cost_buffer/fpga_base_cost_buffer_4x4_1.txt","r")
    f2 = open(".././result/ocd/fpga_base_cost_buffer/fpga_base_cost_buffer_4x4_2.txt","r")
    f3 = open(".././result/ocd/fpga_base_cost_buffer/fpga_base_cost_buffer_4x4_3.txt","r")
    f4 = open(".././result/ocd/fpga_base_cost_buffer/fpga_base_cost_buffer_4x4_4.txt","r")
    f5 = open(".././result/ocd/fpga_base_cost_buffer/fpga_base_cost_buffer_4x4_5.txt","r")
    f6 = open(".././result/ocd/fpga_base_cost_buffer/fpga_base_cost_buffer_4x4_6.txt","r")
    f7 = open(".././result/ocd/fpga_base_cost_buffer/fpga_base_cost_buffer_4x4_7.txt","r")
    f8 = open(".././result/ocd/hpm_base_cost_buffer/hpm_base_cost_buffer_4x4.txt","r")
    txt0 = f0.read()
    txt1 = f1.read()
    txt2 = f2.read()
    txt3 = f3.read()
    txt4 = f4.read()
    txt5 = f5.read()
    txt6 = f6.read()
    txt7 = f7.read()
    txt8 = f8.read()
    if txt0 == txt1 == txt2 == txt3 == txt4 == txt5 == txt6 == txt7 == txt8:
        print("base_cost_buffer 4x4 : Right!")
    else:
        print("base_cost_buffer 4x4 : False!")

def fun_4x4_lnpd():   
    #lnpd
    print("\nlnpd:")
    f0 = open(".././result/lnpd/fpga_rdoq_last_x/fpga_rdoq_last_x_4x4_0.txt","r")
    f1 = open(".././result/lnpd/fpga_rdoq_last_x/fpga_rdoq_last_x_4x4_1.txt","r")
    f2 = open(".././result/lnpd/fpga_rdoq_last_x/fpga_rdoq_last_x_4x4_2.txt","r")
    f3 = open(".././result/lnpd/fpga_rdoq_last_x/fpga_rdoq_last_x_4x4_3.txt","r")
    f4 = open(".././result/lnpd/fpga_rdoq_last_x/fpga_rdoq_last_x_4x4_4.txt","r")
    f5 = open(".././result/lnpd/fpga_rdoq_last_x/fpga_rdoq_last_x_4x4_5.txt","r")
    f6 = open(".././result/lnpd/fpga_rdoq_last_x/fpga_rdoq_last_x_4x4_6.txt","r")
    f7 = open(".././result/lnpd/fpga_rdoq_last_x/fpga_rdoq_last_x_4x4_7.txt","r")
    f8 = open(".././result/lnpd/hpm_rdoq_last_x/hpm_rdoq_last_x_4x4.txt","r")
    txt0 = f0.read()
    txt1 = f1.read()
    txt2 = f2.read()
    txt3 = f3.read()
    txt4 = f4.read()
    txt5 = f5.read()
    txt6 = f6.read()
    txt7 = f7.read()
    txt8 = f8.read()
    if txt0 == txt1 == txt2 == txt3 == txt4 == txt5 == txt6 == txt7 == txt8:
        print("rdoq_last_x 4x4 : Right!")
    else:
        print("rdoq_last_x 4x4 : False!")



    f0 = open(".././result/lnpd/fpga_rdoq_last_y/fpga_rdoq_last_y_4x4_0.txt","r")
    f1 = open(".././result/lnpd/fpga_rdoq_last_y/fpga_rdoq_last_y_4x4_1.txt","r")
    f2 = open(".././result/lnpd/fpga_rdoq_last_y/fpga_rdoq_last_y_4x4_2.txt","r")
    f3 = open(".././result/lnpd/fpga_rdoq_last_y/fpga_rdoq_last_y_4x4_3.txt","r")
    f4 = open(".././result/lnpd/fpga_rdoq_last_y/fpga_rdoq_last_y_4x4_4.txt","r")
    f5 = open(".././result/lnpd/fpga_rdoq_last_y/fpga_rdoq_last_y_4x4_5.txt","r")
    f6 = open(".././result/lnpd/fpga_rdoq_last_y/fpga_rdoq_last_y_4x4_6.txt","r")
    f7 = open(".././result/lnpd/fpga_rdoq_last_y/fpga_rdoq_last_y_4x4_7.txt","r")
    f8 = open(".././result/lnpd/hpm_rdoq_last_y/hpm_rdoq_last_y_4x4.txt","r")
    txt0 = f0.read()
    txt1 = f1.read()
    txt2 = f2.read()
    txt3 = f3.read()
    txt4 = f4.read()
    txt5 = f5.read()
    txt6 = f6.read()
    txt7 = f7.read()
    txt8 = f8.read()
    if txt0 == txt1 == txt2 == txt3 == txt4 == txt5 == txt6 == txt7 == txt8:
        print("rdoq_last_y 4x4 : Right!")
    else:
        print("rdoq_last_y 4x4 : False!")


    f0 = open(".././result/lnpd/fpga_endPosCost/fpga_endPosCost_4x4_0.txt","r")
    f1 = open(".././result/lnpd/fpga_endPosCost/fpga_endPosCost_4x4_1.txt","r")
    f2 = open(".././result/lnpd/fpga_endPosCost/fpga_endPosCost_4x4_2.txt","r")
    f3 = open(".././result/lnpd/fpga_endPosCost/fpga_endPosCost_4x4_3.txt","r")
    f4 = open(".././result/lnpd/fpga_endPosCost/fpga_endPosCost_4x4_4.txt","r")
    f5 = open(".././result/lnpd/fpga_endPosCost/fpga_endPosCost_4x4_5.txt","r")
    f6 = open(".././result/lnpd/fpga_endPosCost/fpga_endPosCost_4x4_6.txt","r")
    f7 = open(".././result/lnpd/fpga_endPosCost/fpga_endPosCost_4x4_7.txt","r")
    f8 = open(".././result/lnpd/hpm_endPosCost/hpm_endPosCost_4x4.txt","r")
    txt0 = f0.read()
    txt1 = f1.read()
    txt2 = f2.read()
    txt3 = f3.read()
    txt4 = f4.read()
    txt5 = f5.read()
    txt6 = f6.read()
    txt7 = f7.read()
    txt8 = f8.read()
    if txt0 == txt1 == txt2 == txt3 == txt4 == txt5 == txt6 == txt7 == txt8:
        print("endPosCost 4x4 : Right!")
    else:
        print("endPosCost 4x4 : False!")


    f0 = open(".././result/lnpd/fpga_rdoqD64LastOne/fpga_rdoqD64LastOne_4x4_0.txt","r")
    f1 = open(".././result/lnpd/fpga_rdoqD64LastOne/fpga_rdoqD64LastOne_4x4_1.txt","r")
    f2 = open(".././result/lnpd/fpga_rdoqD64LastOne/fpga_rdoqD64LastOne_4x4_2.txt","r")
    f3 = open(".././result/lnpd/fpga_rdoqD64LastOne/fpga_rdoqD64LastOne_4x4_3.txt","r")
    f4 = open(".././result/lnpd/fpga_rdoqD64LastOne/fpga_rdoqD64LastOne_4x4_4.txt","r")
    f5 = open(".././result/lnpd/fpga_rdoqD64LastOne/fpga_rdoqD64LastOne_4x4_5.txt","r")
    f6 = open(".././result/lnpd/fpga_rdoqD64LastOne/fpga_rdoqD64LastOne_4x4_6.txt","r")
    f7 = open(".././result/lnpd/fpga_rdoqD64LastOne/fpga_rdoqD64LastOne_4x4_7.txt","r")
    f8 = open(".././result/lnpd/hpm_rdoqD64LastOne/hpm_rdoqD64LastOne_4x4.txt","r")
    txt0 = f0.read()
    txt1 = f1.read()
    txt2 = f2.read()
    txt3 = f3.read()
    txt4 = f4.read()
    txt5 = f5.read()
    txt6 = f6.read()
    txt7 = f7.read()
    txt8 = f8.read()
    if txt0 == txt1 == txt2 == txt3 == txt4 == txt5 == txt6 == txt7 == txt8:
        print("rdoqD64LastOne 4x4 : Right!")
    else:
        print("rdoqD64LastOne 4x4 : False!")


    f0 = open(".././result/lnpd/fpga_rdoqD64LastZero/fpga_rdoqD64LastZero_4x4_0.txt","r")
    f1 = open(".././result/lnpd/fpga_rdoqD64LastZero/fpga_rdoqD64LastZero_4x4_1.txt","r")
    f2 = open(".././result/lnpd/fpga_rdoqD64LastZero/fpga_rdoqD64LastZero_4x4_2.txt","r")
    f3 = open(".././result/lnpd/fpga_rdoqD64LastZero/fpga_rdoqD64LastZero_4x4_3.txt","r")
    f4 = open(".././result/lnpd/fpga_rdoqD64LastZero/fpga_rdoqD64LastZero_4x4_4.txt","r")
    f5 = open(".././result/lnpd/fpga_rdoqD64LastZero/fpga_rdoqD64LastZero_4x4_5.txt","r")
    f6 = open(".././result/lnpd/fpga_rdoqD64LastZero/fpga_rdoqD64LastZero_4x4_6.txt","r")
    f7 = open(".././result/lnpd/fpga_rdoqD64LastZero/fpga_rdoqD64LastZero_4x4_7.txt","r")
    f8 = open(".././result/lnpd/hpm_rdoqD64LastZero/hpm_rdoqD64LastZero_4x4.txt","r")
    txt0 = f0.read()
    txt1 = f1.read()
    txt2 = f2.read()
    txt3 = f3.read()
    txt4 = f4.read()
    txt5 = f5.read()
    txt6 = f6.read()
    txt7 = f7.read()
    txt8 = f8.read()
    if txt0 == txt1 == txt2 == txt3 == txt4 == txt5 == txt6 == txt7 == txt8:
        print("rdoqD64LastZero 4x4 : Right!")
    else:
        print("rdoqD64LastZero 4x4 : False!")


    f0 = open(".././result/lnpd/fpga_tempCost/fpga_tempCost_4x4_0.txt","r")
    f1 = open(".././result/lnpd/fpga_tempCost/fpga_tempCost_4x4_1.txt","r")
    f2 = open(".././result/lnpd/fpga_tempCost/fpga_tempCost_4x4_2.txt","r")
    f3 = open(".././result/lnpd/fpga_tempCost/fpga_tempCost_4x4_3.txt","r")
    f4 = open(".././result/lnpd/fpga_tempCost/fpga_tempCost_4x4_4.txt","r")
    f5 = open(".././result/lnpd/fpga_tempCost/fpga_tempCost_4x4_5.txt","r")
    f6 = open(".././result/lnpd/fpga_tempCost/fpga_tempCost_4x4_6.txt","r")
    f7 = open(".././result/lnpd/fpga_tempCost/fpga_tempCost_4x4_7.txt","r")
    f8 = open(".././result/lnpd/hpm_tempCost/hpm_tempCost_4x4.txt","r")
    txt0 = f0.read()
    txt1 = f1.read()
    txt2 = f2.read()
    txt3 = f3.read()
    txt4 = f4.read()
    txt5 = f5.read()
    txt6 = f6.read()
    txt7 = f7.read()
    txt8 = f8.read()
    if txt0 == txt1 == txt2 == txt3 == txt4 == txt5 == txt6 == txt7 == txt8:
        print("tempCost 4x4 : Right!")
    else:
        print("tempCost 4x4 : False!")


fun_16x16_pq()
fun_32x32_pq()
fun_8x8_pq()
fun_4x4_pq()

fun_16x16_ocd()
fun_32x32_ocd()
fun_8x8_ocd()
fun_4x4_ocd()

fun_16x16_lnpq()
fun_32x32_lnpd()
fun_8x8_lnpd()
fun_4x4_lnpd()


