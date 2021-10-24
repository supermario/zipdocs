module Frontend.Update exposing
    ( newDocument
    , updateCurrentDocument
    , updateWithViewport
    )

import Document exposing (Document)
import Lamdera exposing (sendToBackend)
import Lang.Lang
import List.Extra
import Types exposing (..)


updateWithViewport vp model =
    let
        w =
            round vp.viewport.width

        h =
            round vp.viewport.height
    in
    ( { model
        | windowWidth = w
        , windowHeight = h
      }
    , Cmd.none
    )


newDocument model =
    let
        emptyDoc =
            Document.empty

        title =
            case model.language of
                Lang.Lang.L1 ->
                    "[title New Document]"

                Lang.Lang.Markdown ->
                    "[! title](New Document)"

                Lang.Lang.MiniLaTeX ->
                    "\\title{New Document}"

        doc =
            { emptyDoc
                | content = title
                , language = model.language
            }
    in
    ( { model | showEditor = True }, sendToBackend (CreateDocument doc) )


updateCurrentDocument : Document -> FrontendModel -> FrontendModel
updateCurrentDocument doc model =
    { model | currentDocument = doc }
