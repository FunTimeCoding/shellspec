#shellcheck shell=sh disable=SC2004,SC2016

% LIB: "$SHELLSPEC_SPECDIR/fixture/lib"
% BIN: "$SHELLSPEC_SPECDIR/fixture/bin"

# This Include do not place inside of Describe. posh fails.
Include "$SHELLSPEC_LIB/core/dsl.sh"

Describe "core/dsl.sh"
  Describe "shellspec_group_id()"
    setup() {
      SHELLSPEC_GROUP_ID="" SHELLSPEC_BLOCK_NO=""
    }
    check() {
      echo "$SHELLSPEC_GROUP_ID"
      echo "$SHELLSPEC_BLOCK_NO"
    }
    BeforeRun setup
    AfterRun check

    It 'sets group id'
      When run shellspec_group_id 10 20
      The line 1 of stdout should eq 10
      The line 2 of stdout should eq 20
    End
  End

  Describe "shellspec_example_id()"
    setup() {
      SHELLSPEC_EXAMPLE_ID="" SHELLSPEC_EXAMPLE_NO="" SHELLSPEC_BLOCK_NO=""
    }
    check() {
      echo "$SHELLSPEC_EXAMPLE_ID"
      echo "$SHELLSPEC_EXAMPLE_NO"
      echo "$SHELLSPEC_BLOCK_NO"
    }
    BeforeRun setup
    AfterRun check

    It 'sets group id'
      When run shellspec_example_id 10 20 30
      The line 1 of stdout should eq 10
      The line 2 of stdout should eq 20
      The line 3 of stdout should eq 30
    End
  End

  Describe "shellspec_metadata()"
    mock() { shellspec_output() { echo "$1"; }; }
    BeforeRun mock

    It 'does not output METADATA if not supplied flag'
      When run shellspec_metadata
      The stdout should not include 'METADATA'
    End

    It 'outputs METADATA if supplied flag'
      When run shellspec_metadata 1
      The stdout should eq 'METADATA'
    End
  End

  Describe "shellspec_finished()"
    mock() { shellspec_output() { echo "$1"; }; }
    BeforeRun mock

    It 'does not output FINISHED if not supplied flag'
      When run shellspec_finished
      The stdout should not include 'FINISHED'
    End

    It 'outputs FINISHED if supplied flag'
      When run shellspec_finished 1
      The stdout should eq 'FINISHED'
    End
  End

  Describe "shellspec_yield()"
    shellspec_yield12345() { echo "yield12345 $#"; }
    echo_lineno() { echo "[$SHELLSPEC_LINENO]"; }
    BeforeRun "SHELLSPEC_BLOCK_NO=12345"
    AfterRun echo_lineno

    It 'calls current block'
      When run shellspec_yield
      The line 1 of stdout should eq "yield12345 0"
      The line 2 of stdout should eq "[]"
    End

    It 'calls current block with arguments'
      When run shellspec_yield arg
      The line 1 of stdout should eq "yield12345 1"
      The line 2 of stdout should eq "[]"
    End
  End

  Describe "shellspec_begin()"
    mock() { shellspec_output() { echo "$1"; }; }
    echo_specfile_specno() { echo "$SHELLSPEC_SPECFILE $SHELLSPEC_SPEC_NO"; }
    BeforeRun mock
    AfterRun echo_specfile_specno

    It 'outputs BEGIN'
      When run shellspec_begin specfile 123
      The line 1 of stdout should eq "BEGIN"
      The line 2 of stdout should eq "specfile 123"
    End
  End

  Describe "shellspec_perform()"
    echo_enabled_filter() { echo "$SHELLSPEC_ENABLED $SHELLSPEC_FILTER"; }
    AfterRun echo_enabled_filter

    It 'sets filter variables'
      When run shellspec_perform enabled filter
      The stdout should eq "enabled filter"
    End
  End

  Describe "shellspec_end()"
    mock() { shellspec_output() { echo "$1"; }; }
    echo_example_count() { echo "$SHELLSPEC_EXAMPLE_COUNT"; }
    BeforeRun mock
    AfterRun echo_example_count

    It 'outputs END'
      When run shellspec_end 1234
      The line 1 of stdout should eq "END"
      The line 2 of stdout should eq "1234"
    End
  End

  Describe "shellspec_description()"
    BeforeRun SHELLSPEC_DESCRIPTION=
    BeforeRun SHELLSPEC_LINENO_BEGIN=10 SHELLSPEC_LINENO_END=20
    AfterRun 'echo "$SHELLSPEC_DESCRIPTION"'

    It 'builds description'
      When run shellspec_description example_group desc
      The stdout should eq "desc$SHELLSPEC_VT"
    End

    It 'translates @ to example lineno'
      When run shellspec_description example @
      The stdout should eq "<example:10-20>"
    End
  End

  Describe "shellspec_example_group()"
    mock() {
      shellspec_output() { echo "$1"; }
      shellspec_yield() { echo 'yield'; }
    }
    It 'calls yield block'
      BeforeRun mock
      When run shellspec_example_group
      The stdout should include 'yield'
    End
  End

  Describe "shellspec_example_block()"
    mock() {
      shellspec_parameters() { echo "called shellspec_parameters" "$@"; }
      shellspec_example123() { echo "called shellspec_example123"; }
    }

    It 'calls shellspec_parameters if not defined SHELLSPEC_PARAMETER_NO exists'
      BeforeRun mock SHELLSPEC_PARAMETER_NO=1000 SHELLSPEC_BLOCK_NO=123
      When run shellspec_example_block
      The stdout should eq 'called shellspec_parameters 1'
    End

    It 'calls shellspec_example if defined SHELLSPEC_PARAMETER_NO'
      BeforeRun mock SHELLSPEC_PARAMETER_NO= SHELLSPEC_BLOCK_NO=123
      When run shellspec_example_block
      The stdout should eq 'called shellspec_example123'
    End
  End

  Describe "shellspec_parameters()"
    shellspec_parameters1000() { echo shellspec_parameters1000; }
    shellspec_parameters1001() { echo shellspec_parameters1001; }
    shellspec_parameters1002() { echo shellspec_parameters1002; }

    It 'calls shellspec_parameters if not defined SHELLSPEC_PARAMETER_NO exists'
      BeforeRun SHELLSPEC_PARAMETER_NO=1002
      When run shellspec_parameters 1000
      The line 1 of stdout should eq 'shellspec_parameters1000'
      The line 2 of stdout should eq 'shellspec_parameters1001'
      The line 3 of stdout should eq 'shellspec_parameters1002'
      The lines of stdout should eq 3
    End
  End

  Describe "shellspec_parameterized_example()"
    shellspec_example0() { IFS=' '; echo "shellspec_example ${*:-}"; }
    setup() {
      SHELLSPEC_BLOCK_NO=0
      SHELLSPEC_EXAMPLE_NO=123
      SHELLSPEC_STDIO_FILE_BASE=1-2-3
    }
    check() {
      echo $SHELLSPEC_EXAMPLE_NO
      echo $SHELLSPEC_STDIO_FILE_BASE
    }
    BeforeRun setup
    AfterRun check

    It 'calls shellspec_example0'
      When run shellspec_parameterized_example
      The line 1 of stdout should eq 'shellspec_example '
      The line 2 of stdout should eq 124
      The line 3 of stdout should eq "1-2-3#1"
    End

    It 'calls shellspec_example0 with arguments'
      When run shellspec_parameterized_example arg
      The line 1 of stdout should eq 'shellspec_example arg'
      The line 2 of stdout should eq 124
      The line 3 of stdout should eq "1-2-3#1"
    End

    It 'increments SHELLSPEC_STDIO_FILE_BASE number'
      BeforeRun "SHELLSPEC_STDIO_FILE_BASE=1-2-3#1"
      When run shellspec_parameterized_example arg
      The line 1 of stdout should eq 'shellspec_example arg'
      The line 2 of stdout should eq 124
      The line 3 of stdout should eq "1-2-3#2"
    End
  End

  Describe "shellspec_example()"
    mock() {
      shellspec_profile_start() { :; }
      shellspec_profile_end() { :; }
      shellspec_output() { echo "$1"; }
    }
    BeforeRun mock prepare

    Context 'when example is execution target'
      prepare() { shellspec_invoke_example() { echo 'invoke_example'; }; }
      BeforeRun SHELLSPEC_ENABLED=1 SHELLSPEC_FILTER=1 SHELLSPEC_DRYRUN=''
      func() { printf foo; false; printf bar; }

      Context 'errexit is on'
        Set 'errexit:on'

        It 'invokes example'
          When run shellspec_example 'description'
          The stdout should include 'invoke_example'
        End

        It 'invokes example with arguments'
          When run shellspec_example 'description' -- tag
          The stdout should include 'invoke_example'
        End

        Specify "The func() stops with 'false' with run evaluation"
          Skip if 'shell flag handling broken' posh_shell_flag_bug
          When run func
          The stdout should eq 'foo'
          The status should be failure
        End

        Specify "The func() does NOT stop with 'false' with call evaluation"
          When call func
          The stdout should eq 'foobar'
          The status should be success
        End
      End

      Context 'errexit is off'
        Set 'errexit:off'

        It 'invokes example'
          When run shellspec_example 'description'
          The stdout should include 'invoke_example'
        End

        It 'invokes example with arguments'
          When run shellspec_example 'description' -- tag
          The stdout should include 'invoke_example'
        End

        Specify "The func() does not stop with 'false' with run evaluation"
          When run func
          The stdout should eq 'foobar'
          The status should be success
        End

        Specify "The func() does not stop with 'false' with run evaluation"
          When call func
          The stdout should eq 'foobar'
          The status should be success
        End
      End

      Context 'errexit is off (by default)'
        Before "SHELLSPEC_ERREXIT=+e"

        Specify "The func() does not stop with 'false' with run evaluation"
          When run func
          The stdout should eq 'foobar'
          The status should be success
        End

        Specify "The func() does not stop with 'false' with run evaluation"
          When call func
          The stdout should eq 'foobar'
          The status should be success
        End
      End
    End

    Context 'when example is aborted'
      prepare() { shellspec_invoke_example() { return 12; }; }
      BeforeRun SHELLSPEC_ENABLED=1 SHELLSPEC_FILTER=1 SHELLSPEC_DRYRUN=''

      It 'outputs abort protocol'
        When run shellspec_example
        The stdout should include 'ABORTED'
        The stdout should include 'FAILED'
      End
    End

    Context 'when example is not execution target'
      prepare() { shellspec_invoke_example() { echo 'invoke_example'; }; }
      BeforeRun SHELLSPEC_ENABLED='' SHELLSPEC_FILTER='' SHELLSPEC_DRYRUN=''

      It 'not invokes example'
        When run shellspec_example
        The stdout should not include 'invoke_example'
      End
    End

    Context 'when dry-run mode'
      prepare() { shellspec_invoke_example() { echo 'invoke_example'; }; }
      BeforeRun SHELLSPEC_ENABLED=1 SHELLSPEC_FILTER=1 SHELLSPEC_DRYRUN=1

      It 'always succeeds'
        When run shellspec_example
        The stdout should not include 'invoke_example'
        The stdout should include 'EXAMPLE'
        The stdout should include 'SUCCEEDED'
      End
    End

    Context 'with tag and parameters'
      prepare() { shellspec_invoke_example() { IFS=' '; echo "$*"; }; }

      It 'passes parameters only'
        When run shellspec_example 'description' tag1 tag2 -- a b c
        The stdout should eq 'a b c'
      End
    End
  End

  Describe "shellspec_invoke_example()"
    expectation() { shellspec_on EXPECTATION; shellspec_off NOT_IMPLEMENTED; }
    mock() {
      shellspec_output() { echo "$1"; }
      shellspec_yield0() { echo "yield $#"; block; }
    }
    BeforeRun SHELLSPEC_BLOCK_NO=0 mock

    It 'skippes the all if skipped outside of example'
      prepare() { shellspec_on SKIP; }
      BeforeRun prepare
      When run shellspec_invoke_example
      The stdout line 1 should equal 'EXAMPLE'
      The stdout line 2 should equal 'SKIP'
      The stdout line 3 should equal 'SKIPPED'
    End

    It 'skipps the rest if skipped inside of example'
      block() { shellspec_skip 1; }
      When run shellspec_invoke_example 1
      The stdout line 1 should equal 'EXAMPLE'
      The stdout line 2 should equal 'yield 1'
      The stdout line 3 should equal 'SKIP'
      The stdout line 4 should equal 'SKIPPED'
    End

    It 'is fail if failed before skipping'
      block() { expectation; shellspec_on FAILED; shellspec_skip 1; }
      When run shellspec_invoke_example
      The stdout line 1 should equal 'EXAMPLE'
      The stdout line 2 should equal 'yield 0'
      The stdout line 3 should equal 'SKIP'
      The stdout line 4 should equal 'FAILED'
    End

    It 'is unimplemented if there is nothing inside of example'
      block() { :; }
      When run shellspec_invoke_example
      The stdout line 1 should equal 'EXAMPLE'
      The stdout line 2 should equal 'yield 0'
      The stdout line 3 should equal 'NOT_IMPLEMENTED'
      The stdout line 4 should equal 'TODO'
    End

    It 'is failed if FAILED switch is on'
      block() { expectation; shellspec_on FAILED; }
      When run shellspec_invoke_example
      The stdout line 1 should equal 'EXAMPLE'
      The stdout line 2 should equal 'yield 0'
      The stdout line 3 should equal 'FAILED'
    End

    It 'is warned and be status unhandled if UNHANDLED_STATUS switch is on'
      block() { expectation; shellspec_on UNHANDLED_STATUS; }
      When run shellspec_invoke_example
      The stdout line 1 should equal 'EXAMPLE'
      The stdout line 2 should equal 'yield 0'
      The stdout line 3 should equal 'UNHANDLED_STATUS'
      The stdout line 4 should equal 'WARNED'
    End

    It 'is warned and be stdout unhandled if UNHANDLED_STDOUT switch is on'
      block() { expectation; shellspec_on UNHANDLED_STDOUT; }
      When run shellspec_invoke_example
      The stdout line 1 should equal 'EXAMPLE'
      The stdout line 2 should equal 'yield 0'
      The stdout line 3 should equal 'UNHANDLED_STDOUT'
      The stdout line 4 should equal 'WARNED'
    End

    It 'is warned and be stderr unhandled if UNHANDLED_STDOUT switch is on'
      block() { expectation; shellspec_on UNHANDLED_STDERR; }
      When run shellspec_invoke_example
      The stdout line 1 should equal 'EXAMPLE'
      The stdout line 2 should equal 'yield 0'
      The stdout line 3 should equal 'UNHANDLED_STDERR'
      The stdout line 4 should equal 'WARNED'
    End

    It 'is success if example ends successfully'
      block() { expectation; }
      When run shellspec_invoke_example
      The stdout line 1 should equal 'EXAMPLE'
      The stdout line 2 should equal 'yield 0'
      The stdout line 3 should equal 'SUCCEEDED'
    End

    It 'is todo if FAILED and PENDING switch is on'
      block() { expectation; shellspec_on FAILED PENDING; }
      When run shellspec_invoke_example
      The stdout line 1 should equal 'EXAMPLE'
      The stdout line 2 should equal 'yield 0'
      The stdout line 3 should equal 'TODO'
    End

    It 'is fixed if PENDING switch is on but not FAILED'
      block() { expectation; shellspec_on PENDING; }
      When run shellspec_invoke_example
      The stdout line 1 should equal 'EXAMPLE'
      The stdout line 2 should equal 'yield 0'
      The stdout line 3 should equal 'FIXED'
    End

    Context 'when --warning-as-failure'
      BeforeRun SHELLSPEC_WARNING_AS_FAILURE=1

      It 'is todo if PENDING switch is on and WARNED'
        block() { expectation; shellspec_on PENDING WARNED; }
        When run shellspec_invoke_example
        The stdout line 1 should equal 'EXAMPLE'
        The stdout line 2 should equal 'yield 0'
        The stdout line 3 should equal 'TODO'
      End
    End

    Context 'when --no-warning-as-failure'
      BeforeRun SHELLSPEC_WARNING_AS_FAILURE=''

      It 'is todo if PENDING switch is on and FIXED'
        block() { expectation; shellspec_on PENDING WARNED; }
        When run shellspec_invoke_example
        The stdout line 1 should equal 'EXAMPLE'
        The stdout line 2 should equal 'yield 0'
        The stdout line 3 should equal 'FIXED'
      End
    End

    It 'is failure if shellspec_call_before_each_hooks failed'
      mock_hooks() { shellspec_before 'return 1'; }
      BeforeRun mock_hooks
      block() { expectation; }
      When run shellspec_invoke_example
      The stdout line 1 should equal 'EXAMPLE'
      The stdout line 2 should equal 'FAILED_BEFORE_EACH_HOOK'
      The stdout line 3 should equal 'FAILED'
      The stdout should not include 'yield'
    End

    It 'is failure if shellspec_call_after_each_hooks failed'
      mock_hooks() { shellspec_after 'return 1'; }
      BeforeRun mock_hooks
      block() { expectation; }
      When run shellspec_invoke_example
      The stdout line 1 should equal 'EXAMPLE'
      The stdout line 3 should equal 'FAILED_AFTER_EACH_HOOK'
      The stdout line 4 should equal 'FAILED'
      The stdout should include 'yield'
    End
  End

  Describe "shellspec_around_call()"
    _around_call() {
      eval 'shellspec_call_before_hooks() { echo "before" "$@"; }'
      eval 'shellspec_call_after_hooks() { echo "after" "$@"; }'
      shellspec_around_call "$@" &&:
      set -- $?
      eval 'shellspec_call_before_hooks() { :; }'
      eval 'shellspec_call_after_hooks() { :; }'
      return "$1"
    }

    It 'calls statement'
      When run _around_call echo ok
      The line 1 of stdout should eq "before CALL"
      The line 2 of stdout should eq "ok"
      The line 3 of stdout should eq "after CALL"
    End

    Context "when error occured in before hooks"
      _around_call() {
        # shellcheck disable=SC2034
        SHELLSPEC_HOOK="hook name"
        eval 'shellspec_call_before_hooks() { echo "before" "$@"; return 12; }'
        eval 'shellspec_call_after_hooks() { echo "after" "$@"; }'
        shellspec_around_call "$@" &&:
        set -- $?
        eval 'shellspec_call_before_hooks() { :; }'
        eval 'shellspec_call_after_hooks() { :; }'
        return "$1"
      }

      It 'calls statement'
        When run _around_call echo ok
        The line 1 of stdout should eq "before CALL"
        The line 2 of stdout should not eq "ok"
        The line 3 of stdout should not eq "after CALL"
        The stderr should include "hook name"
        The status should eq 12
      End
    End

    Context "when error occured in after hooks"
      _around_call() {
        # shellcheck disable=SC2034
        SHELLSPEC_HOOK="hook name"
        eval 'shellspec_call_before_hooks() { echo "before" "$@"; }'
        eval 'shellspec_call_after_hooks() { echo "after" "$@"; return 12; }'
        shellspec_around_call "$@" &&:
        set -- $?
        eval 'shellspec_call_before_hooks() { :; }'
        eval 'shellspec_call_after_hooks() { :; }'
        return "$1"
      }

      It 'calls statement'
        When run _around_call echo ok
        The line 1 of stdout should eq "before CALL"
        The line 2 of stdout should eq "ok"
        The line 3 of stdout should eq "after CALL"
        The stderr should include "hook name"
        The status should eq 12
      End
    End
  End

  Describe "shellspec_around_run()"
    _around_run() {
      eval 'shellspec_call_before_hooks() { echo "before" "$@"; }'
      eval 'shellspec_call_after_hooks() { echo "after" "$@"; }'
      shellspec_around_run "$@" &&:
      set -- $?
      eval 'shellspec_call_before_hooks() { :; }'
      eval 'shellspec_call_after_hooks() { :; }'
      return "$1"
    }

    It 'runs statement'
      When run _around_run echo ok
      The line 1 of stdout should eq "before RUN"
      The line 2 of stdout should eq "ok"
      The line 3 of stdout should eq "after RUN"
    End

    Context "when error occured in before hooks"
      _around_run() {
        # shellcheck disable=SC2034
        SHELLSPEC_HOOK="hook name"
        eval 'shellspec_call_before_hooks() { echo "before" "$@"; return 12; }'
        eval 'shellspec_call_after_hooks() { echo "after" "$@"; }'
        shellspec_around_run "$@" &&:
        set -- $?
        eval 'shellspec_call_before_hooks() { :; }'
        eval 'shellspec_call_after_hooks() { :; }'
        return "$1"
      }

      It 'runs statement'
        When run _around_run echo ok
        The line 1 of stdout should eq "before RUN"
        The line 2 of stdout should not eq "ok"
        The line 3 of stdout should not eq "after RUN"
        The stderr should include "hook name"
        The status should eq 12
      End
    End

    Context "when error occured in after hooks"
      _around_run() {
        # shellcheck disable=SC2034
        SHELLSPEC_HOOK="hook name"
        eval 'shellspec_call_before_hooks() { echo "before" "$@"; }'
        eval 'shellspec_call_after_hooks() { echo "after" "$@"; return 12; }'
        shellspec_around_run "$@" &&:
        set -- $?
        eval 'shellspec_call_before_hooks() { :; }'
        eval 'shellspec_call_after_hooks() { :; }'
        return "$1"
      }

      It 'runs statement'
        When run _around_run echo ok
        The line 1 of stdout should eq "before RUN"
        The line 2 of stdout should eq "ok"
        The line 3 of stdout should eq "after RUN"
        The stderr should include "hook name"
        The status should eq 12
      End
    End
  End

  Describe "shellspec_when()"
    init() {
      shellspec_off EVALUATION EXPECTATION
      shellspec_on NOT_IMPLEMENTED
    }

    mock() {
      shellspec_output() { echo "output:$1"; }
      shellspec_statement_evaluation() { :; }
      eval 'shellspec_on() { echo "on:$*"; }'
      eval 'shellspec_off() { echo "off:$*"; }'
    }

    It 'calls evaluation'
      BeforeRun init mock
      When run shellspec_when call true
      The stdout should include 'off:NOT_IMPLEMENTED'
      The stdout should include 'on:EVALUATION'
      The stdout should include 'output:EVALUATION'
    End

    It 'is syntax error when evaluation type missing'
      BeforeRun init mock
      When run shellspec_when
      The stdout should include 'off:NOT_IMPLEMENTED'
      The stdout should include 'on:EVALUATION'
      The stdout should include 'on:FAILED'
      The stdout should include 'output:SYNTAX_ERROR'
    End

    It 'is syntax error when evaluation missing'
      BeforeRun init mock
      When run shellspec_when call
      The stdout should include 'off:NOT_IMPLEMENTED'
      The stdout should include 'on:EVALUATION'
      The stdout should include 'on:FAILED'
      The stdout should include 'output:SYNTAX_ERROR'
    End

    It 'is syntax error when already executed evaluation'
      prepare() { shellspec_on EVALUATION; }
      BeforeRun init prepare mock
      When run shellspec_when call true
      The stdout line 1 should equal 'off:NOT_IMPLEMENTED'
      The stdout line 2 should equal 'output:SYNTAX_ERROR_EVALUATION'
      The stdout line 3 should equal 'on:FAILED'
    End

    It 'is syntax error when already executed expectation'
      prepare() { shellspec_on EXPECTATION; }
      BeforeRun init prepare mock
      When run shellspec_when
      The stdout should include 'off:NOT_IMPLEMENTED'
      The stdout should include 'on:EVALUATION'
      The stdout should include 'on:FAILED'
      The stdout should include 'output:SYNTAX_ERROR'
    End
  End

  Describe "shellspec_statement()"
    shellspec__statement_() { echo 'called'; }
    inspect() {
      shellspec_if SYNTAX_ERROR && echo 'SYNTAX_ERROR:on' || echo 'SYNTAX_ERROR:off'
      shellspec_if FAILED && echo 'FAILED:on' || echo 'FAILED:off'
    }
    AfterRun inspect

    It 'calls statement'
      When run shellspec_statement _statement_ dummy
      The stdout should include 'SYNTAX_ERROR:off'
      The stdout should include 'FAILED:off'
      The stdout should include 'called'
    End

    It 'is syntax error when statement raises syntax error'
      shellspec__statement_() { shellspec_on SYNTAX_ERROR; }
      When run shellspec_statement _statement_ dummy
      The stdout should include 'SYNTAX_ERROR:on'
      The stdout should include 'FAILED:on'
      The stdout should not include 'called'
    End

    It 'does not call statement when already skipped'
      prepare() { shellspec_on SKIP; }
      BeforeRun prepare
      When run shellspec_statement _statement_ dummy
      The stdout should not include 'called'
    End
  End

  Describe "shellspec_the()"
    prepare() { shellspec_on NOT_IMPLEMENTED; }

    mock() {
      shellspec_statement_preposition() { echo expectation; }
      shellspec_output() { echo "output:$1"; }
      eval 'shellspec_on() { echo "on:$*"; }'
      eval 'shellspec_off() { echo "off:$*"; }'
    }

    It 'calls expectation'
      BeforeRun prepare mock
      When run shellspec_the expectation
      The stdout should not include 'output:SYNTAX_ERROR_EXPECTATION'
      The stdout should include 'off:NOT_IMPLEMENTED'
      The stdout should include 'on:EXPECTATION'
      The stdout should not include 'on:FAILED'
      The stdout should include 'expectation'
    End

    It 'calls expectation'
      BeforeRun prepare mock
      When run shellspec_the
      The stdout should include 'output:SYNTAX_ERROR_EXPECTATION'
      The stdout should include 'off:NOT_IMPLEMENTED'
      The stdout should include 'on:EXPECTATION'
      The stdout should include 'on:FAILED'
      The stdout should not include 'expectation'
    End
  End

  Describe "shellspec_path()"
    echo_path_alias() { echo "$SHELLSPEC_PATH_ALIAS"; }
    AfterRun echo_path_alias

    It 'sets path alias'
      When run shellspec_path path1 path2 path3
      The stdout should eq ":path1:path2:path3:"
    End
  End

  Describe "shellspec_skip()"
    init() { SHELLSPEC_EXAMPLE_NO=1; }
    mock() {
      shellspec_output() { echo "output:$1"; }
    }
    inspect() {
      shellspec_if SKIP && echo 'SKIP:on' || echo 'SKIP:off'
      echo "skip_id:${SHELLSPEC_SKIP_ID-[unset]}"
      echo "skip_reason:${SHELLSPEC_SKIP_REASON-[unset]}"
      echo "example_no:${SHELLSPEC_EXAMPLE_NO-[unset]}"
    }
    BeforeRun init mock
    AfterRun inspect

    It 'skips example when inside of example'
      When run shellspec_skip 123 "reason"
      The stdout should include 'output:SKIP'
      The stdout should include 'SKIP:on'
      The stdout should include 'skip_id:123'
      The stdout should include 'skip_reason:reason'
      The stdout should include 'example_no:1'
    End

    It 'skips example when outside of example'
      init() { SHELLSPEC_EXAMPLE_NO=; }
      When run shellspec_skip 123 "skip reason"
      The stdout line 1 should equal 'SKIP:on'
    End

    It 'do nothing when already skipped'
      prepare() { shellspec_on SKIP; }
      BeforeRun prepare
      When run shellspec_skip 123 "skip reason"
      The stdout should not include 'output:SKIP'
      The stdout should include 'SKIP:on'
      The stdout should include 'skip_id:[unset]'
      The stdout should include 'skip_reason:[unset]'
      The stdout should include 'example_no:1'
    End

    It 'skips example when satisfy condition'
      When run shellspec_skip 123 if "reason" true
      The stdout should include 'output:SKIP'
      The stdout should include 'SKIP:on'
    End

    It 'does not skip example when not satisfy condition'
      When run shellspec_skip 123 if "reason" false
      The stdout should not include 'output:SKIP'
      The stdout should include 'SKIP:off'
    End
  End

  Describe "shellspec_pending()"

    init() { SHELLSPEC_EXAMPLE_NO=1; }
    mock() {
      shellspec_output() { echo "output:$1"; }
    }
    inspect() {
      shellspec_if PENDING && echo 'pending:on' || echo 'pending:off'
    }
    BeforeRun init mock
    AfterRun inspect

    It 'pending example when inside of example'
      When run shellspec_pending
      The stdout should include 'output:PENDING'
      The stdout should include 'pending:on'
    End

    It 'does not pending example when already failed'
      prepare() { shellspec_on FAILED; }
      BeforeRun prepare
      When run shellspec_pending
      The stdout should include 'output:PENDING'
      The stdout should include 'pending:off'
    End

    It 'does not pending example when already skipped'
      prepare() { shellspec_on SKIP; }
      BeforeRun prepare
      When run shellspec_pending
      The stdout should not include 'output:PENDING'
      The stdout should include 'pending:off'
    End

    It 'does not pending example when outside of example'
      prepare() { SHELLSPEC_EXAMPLE_NO=; }
      BeforeRun prepare
      When run shellspec_pending
      The stdout should not include 'output:PENDING'
      The stdout should include 'pending:on'
    End
  End

  Describe "Include"
    Include "$LIB/include.sh" # comment
    Before 'unset __SOURCED__ ||:'

    It 'includes script'
      The result of "foo()" should eq "foo"
    End

    It 'supplies __SOURCED__ variable'
      The output should be blank
      The result of "get_sourced()" should eq "$LIB/include.sh"
    End

    It 'handles readonly correctly'
      The variable value should eq 123
    End
  End

  Describe "shellspec_logger()"
    It 'outputs to logfile'
      logger_test() {
        shellspec_logger "logger test1"
        shellspec_logger "logger test2"
      }
      Path log="$SHELLSPEC_TMPBASE/test-logfile"
      BeforeCall SHELLSPEC_LOGFILE="$SHELLSPEC_TMPBASE/test-logfile"
      When call logger_test
      The line 1 of contents of file log should eq "logger test1"
      The line 2 of contents of file log should eq "logger test2"
    End

    It 'sleeps to make the log easy to read'
      sleep() { echo sleep; }
      BeforeCall SHELLSPEC_LOGFILE=/dev/null
      When call shellspec_logger "logger test"
      The stdout should eq "sleep"
    End
  End

  Describe "shellspec_deprecated()"
    It 'outputs to logfile'
      Path log="$SHELLSPEC_TMPBASE/test-deprecation.log"
      BeforeRun SHELLSPEC_SPECFILE=spec.sh SHELLSPEC_LINENO=10
      BeforeRun SHELLSPEC_DEPRECATION_LOGFILE=test-deprecation.log
      When run shellspec_deprecated "deprecated test"
      The contents of file log should eq "spec.sh:10 deprecated test"
    End
  End

  Describe "shellspec_intercept()"
    It 'registor interceptor with default name'
      When call shellspec_intercept foo
      The variable SHELLSPEC_INTERCEPTOR should eq "|foo:__foo__|"
    End

    It 'registor interceptor with specified name'
      When call shellspec_intercept foo:bar
      The variable SHELLSPEC_INTERCEPTOR should eq "|foo:bar|"
    End

    It 'registor interceptor with same name'
      When call shellspec_intercept foo:
      The variable SHELLSPEC_INTERCEPTOR should eq "|foo:foo|"
    End

    It 'registor multiple interceptors at once'
      When call shellspec_intercept foo bar
      The variable SHELLSPEC_INTERCEPTOR should eq "|foo:__foo__|bar:__bar__|"
    End
  End

  Describe "shellspec_set()"
    shellspec_append_shell_option() { echo "$1 $2"; }

    It 'calls shellspec_append_shell_option'
      When run shellspec_set errexit:on noglob:off
      The line 1 of stdout should eq "SHELLSPEC_SHELL_OPTIONS errexit:on"
      The line 2 of stdout should eq "SHELLSPEC_SHELL_OPTIONS noglob:off"
    End
  End

  Describe "shellspec_marker()"
    It 'outputs maker'
      When run shellspec_marker specfile 1234
      The stderr should eq "${SHELLSPEC_SYN}shellspec_marker:specfile 1234"
    End
  End

  Describe "shellspec_abort()"
    It 'aborts'
      When run shellspec_abort
      The stderr should be blank
      The status should eq 1
    End

    It 'aborts with exit status'
      When run shellspec_abort 12
      The stderr should be blank
      The status should eq 12
    End

    It 'aborts with message'
      When run shellspec_abort 1 'error'
      The stderr should eq 'error'
      The status should be failure
    End

    It 'aborts with extra message'
      When run shellspec_abort 1 'error' 'extra'
      The line 1 of stderr should eq 'error'
      The line 2 of stderr should eq 'extra'
      The status should be failure
    End
  End

  Describe "shellspec_is_temporary_skip()"
    Parameters
      ""            success
      "# comment"   success
      "reason"      failure
    End

    temporary_skip() {
      SHELLSPEC_SKIP_REASON=$1
      shellspec_is_temporary_skip
    }

    It "detects temporary skip"
      When run temporary_skip "$1"
      The status should be "$2"
    End
  End

  Describe "shellspec_is_temporary_pending()"
    Parameters
      ""            success
      "# comment"   success
      "reason"      failure
    End

    temporary_pending() {
      # shellcheck disable=SC2034
      SHELLSPEC_PENDING_REASON=$1
      shellspec_is_temporary_pending
    }

    It "detects temporary pending"
      When run temporary_pending "$1"
      The status should be "$2"
    End
  End

  Describe "shellspec_cat"
    Data
    #|test1
    #|test2
    End

    It "outputs data"
      When call shellspec_cat
      The line 1 of stdout should eq "test1"
      The line 2 of stdout should eq "test2"
    End
  End

  Describe 'BeforeCall / AfterCall'
    before() { echo before; }
    after() { echo after; }
    foo() { echo foo; }
    BeforeCall before
    AfterCall after

    It 'called before / after expectation'
      When call foo
      The line 1 of stdout should eq before
      The line 2 of stdout should eq foo
      The line 3 of stdout should eq after
    End

    It 'can be specified multiple'
      BeforeCall 'echo before2'
      AfterCall 'echo after2'
      When call foo
      The line 1 of stdout should eq before
      The line 2 of stdout should eq before2
      The line 3 of stdout should eq foo
      The line 4 of stdout should eq after2
      The line 5 of stdout should eq after
    End

    It 'calls same scope with evaluation'
      before() { value='before'; }
      foo() { value="$value foo"; }
      after() { echo "$value after"; }
      When call foo
      The stdout should eq "before foo after"
    End

    Describe 'BeforeCall'
      It 'failed and evaluation not call'
        before() { return 123; }
        When call foo
        The stdout should not include 'foo'
        The status should eq 123
        The stderr should be present
      End
    End

    Describe 'AfterCall'
      Context 'errexit is on'
        Set errexit:on
        It 'not called when evaluation failure'
          foo() { echo foo; false; }
          When call foo
          The line 1 of stdout should eq before
          The line 2 of stdout should eq foo
          The line 3 of stdout should be undefined
          The status should be failure
        End
      End

      Context 'errexit is off'
        Set errexit:off
        It 'not called when evaluation failure'
          foo() { echo foo; false; }
          When call foo
          The line 1 of stdout should eq before
          The line 2 of stdout should eq foo
          The line 3 of stdout should be undefined
          The status should be failure
        End
      End

      It 'fails cause evaluation to be failure'
        after() { return 123; }
        When call foo
        The status should eq 123
        The line 1 of stdout should eq 'before'
        The line 2 of stdout should eq 'foo'
        The stderr should be present
      End
    End
  End

  Describe 'BeforeRun / AfterRun'
    before() { echo before; }
    after() { echo after; }
    foo() { echo foo; }
    BeforeRun before
    AfterRun after

    It 'run before / after expectation'
      When run foo
      The line 1 of stdout should eq before
      The line 2 of stdout should eq foo
      The line 3 of stdout should eq after
    End

    It 'can be specified multiple'
      BeforeRun 'echo before2'
      AfterRun 'echo after2'
      When run foo
      The line 1 of stdout should eq before
      The line 2 of stdout should eq before2
      The line 3 of stdout should eq foo
      The line 4 of stdout should eq after2
      The line 5 of stdout should eq after
    End

    It 'runs same scope with evaluation'
      before() { value='before'; }
      foo() { value="$value foo"; }
      after() { echo "$value after"; }
      When run foo
      The stdout should eq "before foo after"
    End

    Describe 'BeforeRun'
      It 'failed and evaluation not run'
        before() { return 123; }
        When run foo
        The stdout should not include 'foo'
        The status should eq 123
        The stderr should be present
      End
    End

    Describe 'AfterRun'
      Context 'errexit is on'
        Set errexit:on
        It 'not run when evaluation failure'
          foo() { echo foo; false; }
          When run foo
          The line 1 of stdout should eq before
          The line 2 of stdout should eq foo
          The line 3 of stdout should be undefined
          The status should be failure
        End
      End

      Context 'errexit is off'
        Set errexit:off
        It 'not run when evaluation failure'
          foo() { echo foo; false; }
          When run foo
          The line 1 of stdout should eq before
          The line 2 of stdout should eq foo
          The line 3 of stdout should be undefined
          The status should be failure
        End
      End

      It 'fails cause evaluation to be failure'
        after() { return 123; }
        When run foo
        The status should eq 123
        The line 1 of stdout should eq 'before'
        The line 2 of stdout should eq 'foo'
        The stderr should be present
      End
    End
  End

  Describe "shellspec_filter()"
    setup() {
      SHELLSPEC_ENABLED="" SHELLSPEC_FILTER="" SHELLSPEC_FOCUSED=""
    }
    check() {
      echo "$SHELLSPEC_ENABLED"
      echo "$SHELLSPEC_FOCUSED"
      echo "$SHELLSPEC_FILTER"
    }
    BeforeRun setup
    AfterRun check

    It 'sets enabled flag'
      When run shellspec_filter 1
      The line 1 of stdout should be present
      The line 2 of stdout should be blank
      The line 3 of stdout should be blank
    End

    It 'sets focused flag'
      When run shellspec_filter "" 1
      The line 1 of stdout should be blank
      The line 2 of stdout should be present
      The line 3 of stdout should be blank
    End

    It 'sets filter flag'
      When run shellspec_filter "" "" 1
      The line 1 of stdout should be blank
      The line 2 of stdout should be blank
      The line 3 of stdout should be present
    End
  End
End
