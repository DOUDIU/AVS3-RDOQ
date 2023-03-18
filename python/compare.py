#dct2
f1 = open(".././result/pq_fpga_coeff/pq_fpga_16x16.txt","r")
f2 = open(".././result/pq_hpm_coeff/pq_hpm_16x16.txt","r")
txt1 = f1.read()
txt2 = f2.read()
if txt1 == txt2:
    print("pq 16x16 : Right!")
else:
    print("pq 16x16 : False!")


