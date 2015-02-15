# Reproducible Research: Peer Assessment 1
It is now possible to collect a large amount of data about personal
movement using activity monitoring devices such as a
[Fitbit](http://www.fitbit.com), [Nike
Fuelband](http://www.nike.com/us/en_us/c/nikeplus-fuelband), or
[Jawbone Up](https://jawbone.com/up). These type of devices are part of
the "quantified self" movement -- a group of enthusiasts who take
measurements about themselves regularly to improve their health, to
find patterns in their behavior, or because they are tech geeks. But
these data remain under-utilized both because the raw data are hard to
obtain and there is a lack of statistical methods and software for
processing and interpreting the data.

This analysis makes use of data from a personal activity monitoring
device. This device collects data at 5 minute intervals through out the
day. The data consists of two months of data from an anonymous
individual collected during the months of October and November, 2012
and include the number of steps taken in 5 minute intervals each day.

## Loading and preprocessing the data
1. Load the data for my analysis:

```r
activities <- read.csv("activity.csv", na.strings="NA")
```

2. Process and transform the data into a suitable format for my analysis:

```r
## I prefer data tables because they are fast and full featured
## for summarizing and aggregating data
library(data.table)
activityDt <- data.table(activities)
activityDt$date <- as.Date(activityDt$date)
```

## What is mean total number of steps taken per day?
1. The number of steps taken per day:

```r
stepsByDay <- activityDt[,sum(steps), by=date]
```

2. A histogram of the number of steps taken each day:

```r
hist(stepsByDay$V1, xlab="Steps By Day", main="Histogram of Steps By Day")
```

![](./PA1_template_files/figure-html/unnamed-chunk-4-1.png) 

3. The mean number of steps taken per day:

```r
mean(stepsByDay$V1, na.rm=T)
```

```
## [1] 10766.19
```

4. The median number of steps taken per day:

```r
median(stepsByDay$V1, na.rm=T)
```

```
## [1] 10765
```

## What is the average daily activity pattern?
1. The following is a time series plot of the 5-minute interval (x-axis) and the average number of steps taken, averaged across all days (y-axis):


```r
stepsInterval <- activityDt[,mean(steps, na.rm = T), by=interval]
plot(stepsInterval, type = "l")
```

![](./PA1_template_files/figure-html/unnamed-chunk-7-1.png) 

2. The following shows which 5-minute interval, on average across all the days in the dataset, contains the maximum number of steps:

```r
stepsInterval[, .SD[which.max(V1)]]$interval
```

```
## [1] 835
```

## Imputing missing values
Note that there are a number of days/intervals where there are missing values (coded as NA). The presence of missing days may introduce bias into some calculations or summaries of the data.  The following analysis explores the effects of this bias.

1. The total number of missing values in the dataset (i.e. the total number of rows with NAs):

```r
activityDt[,sum(is.na(steps))]
```

```
## [1] 2304
```

2. Fill in all the missing values of the dataset with the mean for the interval across all days:

```r
activityIntMeans <- activityDt[,as.integer(mean(steps, na.rm=T)), by=interval]
activityNaIntervals <- activityDt[is.na(steps)]$interval
activityNaSteps <- activityIntMeans[interval == activityNaIntervals]$V1
activityDt[is.na(steps), steps := activityNaSteps]
```

```
##        steps       date interval
##     1:     1 2012-10-01        0
##     2:     0 2012-10-01        5
##     3:     0 2012-10-01       10
##     4:     0 2012-10-01       15
##     5:     0 2012-10-01       20
##    ---                          
## 17564:     4 2012-11-30     2335
## 17565:     3 2012-11-30     2340
## 17566:     0 2012-11-30     2345
## 17567:     0 2012-11-30     2350
## 17568:     1 2012-11-30     2355
```

3. A histogram of the total number of steps taken each day (missing values filled in):

```r
stepsByDay <- activityDt[,sum(steps), by=date]
hist(stepsByDay$V1, xlab="Steps By Day", main="Histogram of Steps By Day")
```

![](./PA1_template_files/figure-html/unnamed-chunk-11-1.png) 

4. The mean number of steps taken per day (missing values filled in):

```r
mean(stepsByDay$V1, na.rm=T)
```

```
## [1] 10749.77
```

5. The median number of steps taken per day (missing values filled in):

```r
median(stepsByDay$V1, na.rm=T)
```

```
## [1] 10641
```

By imputing the missing values with the mean for the interval, we don't see a significant differents in the distribution of the steps by day.  The majority of the steps still occur in the middle of the day.  Also we see just a slight decrease in the mean and median steps per day indicating that the time slots where missing values were observed are not times that alot of steps were typically taken

## Are there differences in activity patterns between weekdays and weekends?
NOTE: This analysis uses the dataset with the filled-in missing values filled in.

1. Adding a new factor variable called dayType with two levels - "weekday" and "weekend":

```r
activityDt$dayType <- "Weekday"
activityDt[weekdays(activityDt$date) == "Sunday" | 
           weekdays(activityDt$date) == "Saturday"]$dayType <- "Weekend"
activityDt$dayType <- as.factor(activityDt$dayType)


# Subset data by daytype
activityWeekDay <- activityDt[dayType == "Weekday"]
activityWeekEnd <- activityDt[dayType == "Weekend"]
```

2. The following panel plots show a time series plot of the 5-minute interval and the average number of steps taken, averaged across all weekday days or weekend days.


```r
stepsIntWkDay <- activityWeekDay[,mean(steps, na.rm = T), by=interval]
stepsIntWkEnd <- activityWeekEnd[,mean(steps, na.rm = T), by=interval]
par(mfrow = c(2,1))
plot(stepsIntWkDay, type="l", ylab="Steps", main="Weekday", xlab="")
plot(stepsIntWkEnd, type="l", ylab="Steps", xlab="Time Interval", main="Weekend")
```

![](./PA1_template_files/figure-html/unnamed-chunk-15-1.png) 

It appears from this that more activity occurs during the morning hours during the Weekdays, while generally the Weekend shows alot more activity.  Sadly the subject must have a desk job like me.
