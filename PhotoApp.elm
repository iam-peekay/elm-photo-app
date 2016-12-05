module PhotoApp exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Array exposing (Array)
import Random
import Http

type alias Photo =
  { url : String }


type alias Model =
  { photos : List Photo
  , selectedUrl : Maybe String
  , loadingError : Maybe String
  , chosenSize: ThumbnailSize }


type Msg
  = SelectByUrl String
  | SurpriseMe
  | SetSize ThumbnailSize
  | SelectByIndex Int

type ThumbnailSize
  = Small
  | Medium
  | Large



urlPrefix : String
urlPrefix = 
  "http://elm-in-action.com/"



view : Model -> Html Msg
view model =
  div [ class "content" ]
    [ h1 [] [ text "Photo App" ]
    , button [ onClick SurpriseMe] [ text "Surprise me!" ]
    , h3 [] [ text "Thumbnail Size: " ]
    , div [ id "choose-size" ] (List.map viewSizeChooser [ Small, Medium, Large ])
    , div [ id "thumbnails", class (sizeToString model.chosenSize) ]
      (List.map (viewThumbnail model.selectedUrl) model.photos)
    , viewLarge model.selectedUrl
    ]



viewLarge : Maybe String -> Html Msg
viewLarge maybeUrl = 
  case maybeUrl of
    Nothing -> 
      text ""
    Just url ->
      img [ class "large", src (urlPrefix ++ "large/" ++ url) ] []



viewThumbnail : Maybe String -> Photo -> Html Msg
viewThumbnail selectedUrl thumbnail =
  img [ src (urlPrefix ++ thumbnail.url)
      , classList [ ("selected", selectedUrl == Just thumbnail.url) ]
      , onClick (SelectByUrl thumbnail.url)
      ]
      []



viewSizeChooser : ThumbnailSize -> Html Msg
viewSizeChooser size =
  label [] [ input [ type_ "radio", name "size", onClick (SetSize size) ] []
           , text (sizeToString size)
           ]



sizeToString : ThumbnailSize -> String
sizeToString size =
  case size of
    Small -> 
      "small"
    Medium -> 
      "medium"
    Large -> 
      "large"



initialModel : Model
initialModel = 
  { photos = []
  , selectedUrl = Nothing
  , loadingError = Nothing
  , chosenSize = Medium
  }
  


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model = 
  case msg of
    SelectByUrl url ->
      ( { model | selectedUrl = Just url }, Cmd.none )
    SurpriseMe ->
      let
        randomPhotoPicker = 
          Random.int 0 (List.length model.photos - 1)
      in 
        ( model, Random.generate SelectByIndex randomPhotoPicker )
    SetSize size ->
      ( { model | chosenSize = size }, Cmd.none )
    SelectByIndex index ->
      let 
        newSelectedUrl : Maybe String
        newSelectedUrl = 
          model.photos
            |> Array.fromList
            |> Array.get index
            |> Maybe.map .url
      in 
        ( { model | selectedUrl = newSelectedUrl }, Cmd.none )



main : Program Never Model Msg
main = Html.program
  { init = ( initialModel, Cmd.none )
  , view = view
  , update = update
  , subscriptions = ( \model -> Sub.none )
  }
