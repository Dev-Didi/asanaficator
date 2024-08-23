defmodule StartupTesting do
  import Asanaficator
  
  client = Asanaficator.Client.new(%{access_token: "2/1206186870308538/1206267178181787:91e3819776fd34e7cff5f3eebb6ef6e2"}) 
  me = Asanaficator.User.me client
  export me
  export client
end
