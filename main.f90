module math
    !use mpi_f08
    use mpi
    !include 'mpif.h'
    implicit none

    interface
    subroutine sum__enzyme_autodiff(fnc, x, dx)
        interface
            real function fnc_decal(a)
                real, dimension(:), allocatable, intent(in) :: a
            end function
        end interface
        procedure(fnc_decal) :: fnc
        real, dimension(:), allocatable, intent(in) :: x
        real, dimension(:), allocatable, intent(inout) :: dx 
    end subroutine
    end interface
    
    contains
    
    function localSummation(x) result(localSum)
        real, allocatable, intent(in) :: x(:) 
        real :: localSum
        integer :: i
        localSum = 0
        do i = 1, size(x)
            localSum = localSum + x(i)
        end do
    end function
    
    function globalSummation(x) result(globalSum)
        real, allocatable, intent(in) :: x(:)
        real :: localSum
        real :: globalSum
        integer :: ierror
        localSum = localSummation(x)
        !print *, 'about to call'
        globalSum = 0
        call MPI_Allreduce(localSum, globalSum, 1, MPI_FLOAT, MPI_SUM, MPI_COMM_WORLD, ierror);
        !print *, 'finished call'
    end function

    function grad_sum(x) result(dx)
        real, dimension(:), allocatable, intent(in) :: x
        real, dimension(:), allocatable :: dx 
        allocate(dx(size(x)))
        dx = 0
        
       ! call sum__enzyme_autodiff(globalSummation, x, dx)
    end function 

end module

program app
    use math
    !use mpi_f08
    use mpi
    !include 'mpif.h'
    implicit none

    real, allocatable :: localX(:) 
    real :: globalSum
    integer proc_rank, num_procs, ierror, i

    call MPI_INIT(ierror)
    call MPI_COMM_SIZE(MPI_COMM_WORLD, num_procs, ierror)
    call MPI_COMM_RANK(MPI_COMM_WORLD, proc_rank, ierror)

    print *, 'Hello World from process: ', proc_rank, 'of ', num_procs

    allocate(localX(proc_rank))
    do i=1, size(localX)
        localX(i) = proc_rank
    end do

    globalSum = globalSummation(localX)

    if (proc_rank == 0) then
        print *, "globalSum = ", globalSum
    end if

    call MPI_FINALIZE(ierror)
end program