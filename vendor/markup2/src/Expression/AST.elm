module Expression.AST exposing
    ( Expr(..)
    , args2M
    , getName
    , miniLaTeXStringValue
    , stringValue
    , stringValueOfArgList
    , stringValueOfList
    , reverseContents

    )

import Expression.Token as Token
import Maybe.Extra


type Expr
    = Text String Token.Loc
    | Verbatim String String Token.Loc
    | Arg (List Expr) Token.Loc
    | Expr String (List Expr) Token.Loc
    | Error String



reverseContents : Expr -> Expr
reverseContents expr =
    case expr of

        Expr name args loc ->
            Expr name (List.reverse args) loc

        Arg args loc ->
           Arg  (List.reverse args) loc

        _ -> expr
dummy =
    { begin = 0, end = 0 }


{-| [Text "a b c d"] -> [Text "a b c", Text "d"]
-}
args2M : List Expr -> List Expr
args2M exprList =
    let
        args =
            args2 exprList
    in
    [ Text args.first dummy, Text args.last dummy ]


args2 : List Expr -> { first : String, last : String }
args2 exprList =
    let
        args =
            exprListToStringList exprList |> String.join " " |> String.words

        n =
            List.length args

        first =
            List.take (n - 1) args |> String.join " "

        last =
            List.drop (n - 1) args |> String.join " "
    in
    { first = first, last = last }


exprListToStringList : List Expr -> List String
exprListToStringList exprList =
    List.map getText exprList
        |> Maybe.Extra.values
        |> List.map String.trim
        |> List.filter (\s -> s /= "")


getText : Expr -> Maybe String
getText text =
    case text of
        Text str _ ->
            Just str

        Verbatim _ str _ ->
            Just (String.replace "`" "" str)

        _ ->
            Nothing


getName : Expr -> Maybe String
getName text =
    case text of
        Expr str _ _ ->
            Just str

        _ ->
            Nothing


stringValueOfList : List Expr -> String
stringValueOfList textList =
    String.join " " (List.map stringValue textList)


stringValueOfArgList : List Expr -> String
stringValueOfArgList textList =
    String.join "" (List.map (stringValue >> (\s -> "{" ++ s ++ "}")) textList)



--stringValue : Expr -> String
--stringValue text =
--    case text of
--        Text str _ ->
--            str
--
--        Expr _ textList _ ->
--            String.join " " (List.map stringValue textList)
--
--        Arg textList _ ->
--            String.join " " (List.map stringValue textList)
--
--        Verbatim _ str _ ->
--            str


stringValue : Expr -> String
stringValue text =
    case text of
        Text string _ ->
            string

        Expr _ textList _ ->
            List.map stringValue textList |> String.join "\n"

        Arg textList _ ->
            List.map stringValue textList |> String.join "\n"

        Verbatim _ str _ ->
            str

        Error str ->
            str


miniLaTeXStringValue : Expr -> String
miniLaTeXStringValue text =
    case text of
        Text string _ ->
            string

        Expr name textList _ ->
            [ name ++ "{" ] ++ List.map stringValue textList ++ [ "}" ] |> String.join ""

        Arg textList _ ->
            List.map stringValue textList |> String.join ""

        Verbatim _ str _ ->
            str

        Error str ->
            str
