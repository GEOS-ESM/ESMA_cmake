subroutine test_fms1_io
    use fms_mod, only: file_exist
    implicit none
    logical :: exists
    exists = file_exist('dummy_file')
end subroutine test_fms1_io
