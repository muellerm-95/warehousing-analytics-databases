import pandas as pd
import sqlalchemy
import datetime

#connect to old database
engine = sqlalchemy.create_engine('postgresql://postgres@localhost:5432/foo')

#read from old postgres database foo to pandas
empl = pd.read_sql_query('select * from "empl"',con=engine)
offices = pd.read_sql_query('select * from "offices"',con=engine)
customers = pd.read_sql_query('select * from "customers"',con=engine)
customers = customers.rename(columns={"city": "customer_city", "state": "customer_state", "country": "customer_country"})
products = pd.read_sql_query('select * from "products"',con=engine)
offices = pd.read_sql_query('select * from "offices"',con=engine)
offices = offices.rename(columns={"city": "office_city", "state": "office_state","country": "office_country"})
order_overview = pd.read_sql_query('select * from "order_overview"',con=engine)
order_details = pd.read_sql_query('select * from "order_details"',con=engine)

#create measures table by joining all tables
measures= order_details.merge(products, how = 'inner', on = 'product_code').merge(order_overview, how = 'inner', on = 'order_number').merge(customers, how = 'inner', on = 'customer_number').merge(empl, how = 'inner', left_on = 'sales_rep_employee_number', right_on = 'employee_number').merge(offices, how = 'inner', on = 'office_code')
# drop the columns that are not needed in measures table
measures = measures[['order_number', 'product_code', 'quantity_ordered', 'price_each', 'order_line_number', 'quantity_in_stock', 'buy_price', '_m_s_r_p', 'order_date', 'shipped_date', 'required_date', 'customer_number', 'sales_rep_employee_number', 'credit_limit', 'reports_to', 'office_code']]
#create useful extra tables
measures['revenue']=measures['quantity_ordered']*measures['price_each']
measures['cost']=measures['quantity_ordered']*measures['buy_price']
measures['profit']=measures['revenue']-measures['cost']
measures['margin']=measures['profit']/measures['cost']

#create date dimension table
dates = pd.DataFrame(columns=['dates', 'years', 'day_of_month', 'months', 'day_of_week', 'quarter'])
dates['dates']=measures['order_date'].append(measures['shipped_date']).append(measures['required_date']).drop_duplicates().dropna()
dates['day_of_month'] = dates['dates'].map(lambda x: x.day)
dates['years'] = dates['dates'].map(lambda x: x.year)
dates['months'] = dates['dates'].map(lambda x: x.month)
dates['quarter'] = dates['dates'].map(lambda x: (x.month-1)//3+1)
dates['day_of_week'] = dates['dates'].map(lambda x: x.weekday())
# Use code '1111-11-11' for date that does not exist
dates=dates.append(pd.Series([datetime.date(year = 1111, month = 11, day = 11),None,None,None,None,None],index=['dates', 'years', 'day_of_month', 'months', 'day_of_week', 'quarter']),ignore_index=True)
measures['shipped_date']=measures['shipped_date'].fillna(datetime.date(year = 1111, month = 11, day = 11))
measures['order_date']=measures['order_date'].fillna(datetime.date(year = 1111, month = 11, day = 11))
measures['required_date']=measures['required_date'].fillna(datetime.date(year = 1111, month = 11, day = 11))

#create the other dimension tables
order_line = measures['order_line_number'].drop_duplicates()
offices = offices[['office_code','office_city','office_state','office_country','office_location']]
empl = empl[['employee_number', 'last_name','first_name','job_title']]
customers = customers[['customer_number','customer_name' ,'customer_city' ,'customer_state' ,'customer_country','customer_location']]
products = products[['product_code' ,'product_line' ,'product_name' ,'product_scale' ,'product_vendor' ,'product_description']]
orders = order_overview[['order_number','status','comments' ]]

#connect to new database
engine2 =  sqlalchemy.create_engine('postgresql://postgres@localhost:5432/bar')

# insert new tables into new database
dates.to_sql('dates', engine2, if_exists = 'append', index = False)
offices.to_sql('offices', engine2, if_exists = 'append', index = False)
empl.to_sql('empl', engine2, if_exists = 'append', index = False)
customers.to_sql('customers', engine2, if_exists = 'append', index = False)
products.to_sql('products', engine2, if_exists = 'append', index = False)
orders.to_sql('orders', engine2, if_exists = 'append', index = False)
order_line.to_sql('order_line', engine2, if_exists = 'append', index = False)
measures.to_sql('measures', engine2, if_exists = 'append', index = False)