# BANK-APP

Basic app to make transactions between banks.  
The idea behind is to get a small app which can be customized for different banks and an external service (TA) in charge of the communication (transactions) between different banks.

The approach has been by setting an API instead of an HTML crud for this scenario.\
Only few endpoints have been defined to allow the required operations.\
As it was not a requirement, no authorization has been implemented; Neither for Web Apps nor for TA service.

### Dependencies

An easy setup for Mac can be done with RVM.

* Ruby version.  2.5.1
* Rails version. 5.2.4.4
* Database Sqlite

### Installation

We need to clone the repo twice in 2 different paths to get a working environment

###### - location 1 | Bank A
###### - location 2 | Bank B 
- the file **database.yml** needs to be edited and change all **bank_A** matches for **bank_B**
- under the `/tmp` folder there must be 2 different pid files `tmp/server.pid` & `tmp/ta_server.pid` so **ta_server.pid** needs to be touched.

Then in each of the folders run these commands to install dependencies.

1. Bundle install
2. rake db:create
3. rake db:migrate
4. rake db:seed

### Services

There Are 3 Different Processes we need to run to mock in Dev mode a Microservices Architecture
- location 1 | Bank A
> **rails s -b 0.0.0.0 -p 3000 -P tmp/server.pid  
rails s -b 0.0.0.0 -p 4000 -P tmp/ta_server.pid**
- location 1 | Bank B
> **rails s -p 3001**

There should be **Bank A** web app running in port **3000**,
**Bank B** web app running in port **3001** and **TA** service in port **4000**.

### Data

Basic data to populate database can be found in the file `seeds.rb`.  
Code banks and account numbers for testing need to be read from this file.  
By opening a rails console the different objects could be modified when needed, like updating some account balance.

### DB Modelling

###### Web Apps
. **Bank** - holds data for only one bank\
. **Customer** - all the customer of that bank\
. **Account** - accounts for customer (can have many)\
. **AccountTransaction** - transaction created inter or intra banks\
. **BankConditions** - Set of rules (max amount, commission..) to be aplied for each type of transaction

###### TA service
. **TaBankRegister** - keeps basic data for all existing banks. It allows to discover where the different apps-banks services are.

### Usage

The different requirements can be tested via Postman or any other Http client.\
In the `data` folder there is a **json** collection for all available resources-requests for every bank.\
The field types and names are self explanatory, and they express the intention of the interface for every request.  
The API has been implemented to support versioning from the start, being V1 the one used.

In the `routes.rb` file the different routes of the project can be seen in detail.
There are 3 endpoint related to transfers

        /internal_transaction (inside same bank)
        /external_transaction (between different banks OUT)
        /incoming_transaction (between different banks IN)

There is 1 endpoint related to list transactions

        /transactions/:type

There is 1 endpoint related to TA service to trigger transactions

        /transfer_between_banks

For the different actions ServiceObjects have been used in each case, to isolate logic

    Transfers::Internal.new(internal_transfer_params).call
    Transfers::External.new(external_transfer_params).call
    Transfers::Incoming.new(incoming_transfer_params).call
Same thing for the different clients used by every component

    client = Ta::Client.new(strong_params, bank_to.host)
    ta_client = Client::Bank.new(account_transaction)

When some new type of transfer needs to be implemented, its related conditions could be added to BankCondition, as the current fields
```
    max_amount
    min_amount
    commission
```

### Testing
The test suite can be run by using the command **`bundle exec rspec`**

### Improvements
Because of lack of time there are many things that haven't been done.\
Some of them are out of scope, but some of them are a must.

##### How would you improve your solution? What would be the next steps?

- proper indexing of the DB
- proper setup of all the possible associations, even when not needed now.
- nested routes to make new endpoints more easy to be added
- list of transactions should have some pagination library added.
- We've used a basic system of fields to hold state as strings ('INTERNAL', 'OK'...) but a better way would use a machine state with transitions and rules.
- Dockerize the app.
- app 100% tested.


##### After implementation, is there any design decision that you would have done differently?

- The 30% possibility of failure has been implemented in just one place of the TA service, though could have been attached to many places; again not enough time to solve this piece correctly.
- Instead of isolating the TA service in a different app we've added its content inside of the main repository, BUT been very specific about the naming and used resources, so can be interpreted as an isolated service.
- Working with decimal types has not been straigth forward, probably some library for currency ops would have been usefull.

##### How would you adapt your solution if transfers are not instantaneous?

- I would add the transactions to some background job, and set a worker to check till x number of times if it got a correct response.





