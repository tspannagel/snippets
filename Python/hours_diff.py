# from datetime import datetime

# start= "2023-07-06 12:00:00"
# end="2023-07-06 14:00:00"

# dt_start = datetime.strptime(start, '%Y-%m-%d %H:%M:%S') 
# dt_end =  datetime.strptime(end, '%Y-%m-%d %H:%M:%S') 

# print(dt_start + " | " type(dt_start))

import datetime

start_date = datetime.datetime(2023, 6, 1, 0)  # Specify the start date and time
end_date = datetime.datetime(2023, 6, 3, 23)   # Specify the end date and time

current_date = start_date

for current_date in (start_date + datetime.timedelta(hours=n) for n in range(int((end_date - start_date).total_seconds() / 3600) + 1)):
    print(current_date)