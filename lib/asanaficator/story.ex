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
    target: nil, #Asanaficator.Task (SUBJECT TO CHANGE IN API!!)
    data: nil
  )

  @type t :: %__MODULE__ {
    gid: binary,
    resource_type: binary,
    created_at: binary,
    created_by: Asanaficator.User,
    resource_subtype: binary,
    text: binary,
    target: Asanaficator.Task,
    data: Map
    }

  @nest_fields %{
    created_by: Asanaficator.User, 
    target: Asanaficator.Task
    } 

  def get_nest_fields(), do: @nest_fields 

  @spec new() :: t
  def new(), do: struct(Asanaficator.Story)

  defp store_optionals(data) do
    story_keys = %Asanaficator.Story{}
                  |> Map.keys()
                  |> Enum.map(&Atom.to_string/1)
    opt_data =
      data
      |> Enum.filter(fn {k, _v} -> 
        not Enum.member?(story_keys, k) 
      end)
      |> Enum.into(%{}) 
    IO.inspect(opt_data)

  end
  @doc """ 
  Get a single story.
  ## Example 
    Asanaficator.Story.get_story(client, 1337 :: story_id, %{optfields: likes}
  
  NOTE: If no opt fields are given, relevant conditional fields will be returned and placed in the data field of your story.

  More info at: https://developers.asana.com/reference/getstory
  """
  @spec get_story(Client.t, integer | binary, List.t) :: Asanaficator.Story.t
  def get_story(client \\ %Client{}, story_id, params \\ []) do
    response = get(client, "stories/#{story_id}", params)
    opt_data = store_optionals(response["data"])
    story = cast(Asanaficator.Story, response["data"], @nest_fields)
    Map.put(story, "data", opt_data)
  end

  @doc """
  Get stories associated with a task.
  ## Example
    Asanaficator.Story.get_task_stories(client, 1337 :: task_id, %{optfields: likes}

    More info at: https://developers.asana.com/reference/getstoriesfortask
  """
  @spec get_task_stories(Client.t, integer | binary, List.t) :: [Asanaficator.Story.t]
  def get_task_stories(client \\ %Client{}, task_id, params \\ []) do
    response = get(client, "tasks/#{task_id}/stories", params)
    cast(Asanaficator.Story, response["data"], @nest_fields)
  end
end


