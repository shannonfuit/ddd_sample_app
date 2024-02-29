# how do we assert uniqueness if it is not the identifier

# how is design translated to code, what are the building blocks
# bounded context 
    # lives in own namespace/directory
# commands
    # raises error in controller because validated at initialisation
    # command handlers come from service objects
# domain service, 
    #  not really related to domain logic but used to calculate something 
# events
# aggregates
  # entity + value objects
  # 2 parts: decision making and changing the state
  # replaying state is using the last part, without checks being applied again
  # event sourcing is like having 2 methods where you previously had one
  # the public method corresponds to an action we want to take on an aggregate, it protects business rules and teels what domain event happened if those rules are met
  # the private method maps the consequences of that domain event that happened to the internal state representation

  # read model test:
    # input events, output is persisted state
    # we test if the correct state is persisted to the database based on events. they are tested in isolation without the aggregate and the write side of things

  # aggregate test:
    # input commands, asserting events
    