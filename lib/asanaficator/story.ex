defmodule Asanaficator.Story do
  import Asanaficator
  alias Asanaficator.Client

  @doc """
    Struct for Story, Like all Asana structs, is primariliy sufficiant for creating a story through the API and making further querys.

    This structure is not exhaustive of the data that a story can contain but should be simple to expand in future.

    A full implementation of the story schema would be cumbersome since it contains fields for just about every type of story possible. Instead, the compact story struct is defined here along with a data field (a map) which can be populated once the resource_subtype is found.

    more info on Asana storys at: https://developers.asana.com/reference/stories
  """
  
  defstruct( 
    gid: nil,
    resource_type: "story",
    created_at: "",
    created_by: nil, # Asanaficator.User
    resource_subtype: "",
    text: "",
    data: nil
  )

  @type t :: %__MODULE__ {
    gid: binary,
    resource_type: binary,
    created_at: binary,
    created_by: Asanaficator.User,
    resource_subtype: binary,
    text: binary,
    data: Map
    }

  @nest_fields %{
    created_by: Asanaficator.User
    } 

  def get_nest_fields(), do: @nest_fields 

  @spec new() :: t
  def new(), do: struct(Asanaficator.Story)

  @doc """ 
  Get a single story.
  ## Example 
    Asanaficator.Story.get_story(client, 1337 :: story_id, {optfields: likes}
  
  NOTE: If no opt fields are given, relevant conditional fields will be returned and placed in the data field of your story.

  More info at: https://developers.asana.com/reference/getstory
  """
#  @spec get_story(Client.t, integer | binary, List.t) :: Asanaficator.Story.t
  def get_story(client \\ %Client{}, story_id, params \\ []) do
    response = get(client, "stories/#{story_id}", params)
    IO.inspect(response)
    cast(Asanaficator.Story, response["data"], @nest_fields)
  end
end
