#shellcheck shell=sh

: "${field_shell:-} ${field_shell_type:-} ${field_shell_version:-}"
: "${field_info:-} ${field_type:-}"

create_buffers methods

methods_each() {
  case $field_type in (meta)
    methods '=' "Running: $field_shell "
    if [ "$field_shell_version" ]; then
      methods '+=' "[$field_shell_type $field_shell_version]"
    else
      methods '+=' "[$field_shell_type]"
    fi
    methods '+=' "${field_info:+ }${field_info}${LF}"
  esac
}

methods_output() {
  methods '>>>'
}
