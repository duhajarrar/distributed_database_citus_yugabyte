
#Throughput

# قراءة البيانات من CSV
data <- read.csv("C:/Users/DELL/Downloads/3 workers - Throughput - الورقة1.csv")

# Perform paired t-test
result <- t.test(data$X3WorkersCitus, data$X3WorkersYugabyte)
print(result)


# قراءة البيانات من CSV
data <- read.csv("C:/Users/DELL/Downloads/5 Workers - Throughput - الورقة1 (1).csv")
View(data)
# Perform paired t-test
result <- t.test(data$X5.WorkersCitus, data$X5.WorkersYugabyte)
print(result)


# قراءة البيانات من CSV
data <- read.csv("C:/Users/DELL/Downloads/7Workers Throughput - الورقة1.csv")
View(data)
# Perform paired t-test
result <- t.test(data$X7.WorkersCitus, data$X7.WorkersYugabyte)
print(result)


#Latency

# قراءة البيانات من CSV
data <- read.csv("C:/Users/DELL/Downloads/_Workers - Latency - الورقة1.csv")
View(data)
# Perform paired t-test
result <- t.test(data$X3WorkersCitus, data$X3WorkersYugabyte)
print(result)


# قراءة البيانات من CSV
data <- read.csv("C:/Users/DELL/Downloads/_Workers - Latency - الورقة1.csv")
View(data)
# Perform paired t-test
result <- t.test(data$X5WorkersCitus, data$X5WorkersYugabyte)
print(result)


# قراءة البيانات من CSV
data <- read.csv("C:/Users/DELL/Downloads/_Workers - Latency - الورقة1.csv")
View(data)
# Perform paired t-test
result <- t.test(data$X7WorkersCitus, data$X7WorkersYugabyte)
print(result)





