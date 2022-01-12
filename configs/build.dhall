let Text/concatMapSep =
      https://prelude.dhall-lang.org/v17.1.0/Text/concatMapSep.dhall sha256:c272aca80a607bc5963d1fcb38819e7e0d3e72ac4d02b1183b1afb6a91340840


let WorkflowCall = { Type = {}, default = {=} }
let On = { Type = { workflow_call : Optional WorkflowCall.Type}, default = {Workflow_call =  WorkflowCall} }
let GitHubActions = ./ExtendedSchema.dhall
let ghc_versions = [ "9.0.1", "8.10.7" ]
let matrix = toMap { ghc = ghc_versions }
let strategy = Some GitHubActions.Strategy::{matrix}
let baseHashFiles = ["package.yaml", "stack-\${{matrix.ghc}}.yaml"]
let hashFiles = \(files : List Text) ->
      let seps = Text/concatMapSep ", " Text (\(x : Text) -> "'${x}'") files
      in "\${{ hashFiles(${seps}) }}"

in GitHubActions.Workflow::{
    , name = "Build"
    , on = GitHubActions.On::{ push = Some GitHubActions.Push::{=}}
    , jobs = toMap { checks = GitHubActions.Job::
          { strategy
          , runs-on = GitHubActions.types.RunsOn.ubuntu-latest
          , steps =
                [ GitHubActions.steps.actions/cache {
                    path = "~/.stack"
                  , hashFiles = baseHashFiles
                  , key = "global-stack-\${{matrix.ghc}}"
                  }
                , GitHubActions.Step::{
                    uses = Some "actions/cache@v2"
                  , name = Some "Cache .stack-work"
                  , `with` = Some (toMap {
                        path = "**/.stack-work",
                        key = "\${{runner.os}}-local-stack-\${{matrix.ghc}}-${hashFiles baseHashFiles}-${hashFiles ["**/*.hs"]}",
                        restore-keys =
                          ''
                          ''${{runner.os}}-local-stack-''${{matrix.ghc}}-${hashFiles baseHashFiles}-
                          ''${{runner.os}}-local-stack-''${{matrix.ghc}}-
                          ''
                      })
                  }
                , GitHubActions.steps.actions/setup-haskell (GitHubActions.actions/HaskellSetup::{
                    enable-stack = Some True,
                    ghc-version = Some "\${{matrix.ghc}}",
                    stack-version = Some "2.7.3"
                })
                , GitHubActions.steps.run { run = 
                    ''
                    stack build --system-ghc --test --no-run-tests
                    ''
                  }
                ]
          }
        }
    }