
#Latency

# قراءة البيانات من CSV
data <- read.csv("C:/Users/DELL/Downloads/Transactions - Latency - الورقة1.csv")
View(data)

# Perform paired t-test
result <- t.test(data$X20.000T_Citus, data$X20.000T_Yugabyte)
print(result)

# Perform Mann-Whitney U test
result <- wilcox.test(data$X20.000T_Citus, data$X20.000T_Yugabyte)
print(result)


# قراءة البيانات من CSV
data <- read.csv("C:/Users/DELL/Downloads/Transactions - Latency - الورقة1.csv")
View(data)

# Perform paired t-test
result <- t.test(data$X40.000T_Citus, data$X40.000T_Yugabyte)
print(result)



# Perform paired t-test
result <- t.test(data$X60.000T_Citus, data$X60.000T_Yugabyte)
print(result)



# Perform paired t-test
result <- t.test(data$X80.000T_Citus, data$X80.000T_Yugabyte)
print(result)



# Perform paired t-test
result <- t.test(data$X100.000T_Citus, data$X100.000T_Yugabyte)
print(result)




#Throughput

# قراءة البيانات من CSV
data <- read.csv("C:/Users/DELL/Downloads/Transactions - Throughput - الورقة1.csv")
View(data)

# Perform paired t-test
result <- t.test(data$X20.000T_Citus, data$X20.000T_Yugabyte)
print(result)


# Perform paired t-test
result <- t.test(data$X40.000T_Citus, data$X40.000T_Yugabyte)
print(result)

# Perform paired t-test
result <- t.test(data$X60.000T_Citus, data$X60.000T_Yugabyte)
print(result)


# Perform paired t-test
result <- t.test(data$X80.000T_Citus, data$X80.000T_Yugabyte)
print(result)

# Perform paired t-test
result <- t.test(data$X100.000T_Citus, data$X100.000T_Yugabyte)
print(result)




