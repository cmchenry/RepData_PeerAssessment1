fileUrl <- "https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2Factivity.zip"
fileName <- "activity.zip"

if (!file.exists(fileName)){
  message(paste("Downloading data file:", fileName))
  download.file(fileUrl, fileName, "curl")
  unzip(fileName)
}else{
  message(paste("Data file already downloaded:", fileName))
}