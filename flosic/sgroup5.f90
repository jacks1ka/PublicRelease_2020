! UTEP Electronic Structure Lab (2020)
!	implicit none
	program cluster
	include 'mpif.h'
	integer :: rank, size, key, group, ierr,igroup
	integer :: group_old,new_group,group2
	integer, dimension (:), allocatable  :: old_ranks
	integer :: i, total_groups, total_members
	integer istatus(MPI_STATUS_SIZE)
	integer :: MPI_COMM_WORLD
	character :: group_txt*10
	character :: dir_name*40
	logical :: exist_dir
	real*8 :: part


	call MPI_Init(ierr)
	call MPI_Comm_size(MY_NEW_COM,size,ierr)
	call MPI_Comm_rank(MY_NEW_COM,rank,ierr)

	igroup=1
	total_groups=23
	total_members=16
	allocate(old_ranks(total_members))
	if(rank.eq.0) then
	  do i=1,total_groups
	    group=i-1
	    write(group_txt,'(1I0)') group
	    group_txt=adjustl(group_txt)
	    dir_name='g'//trim(group_txt)//'/'
	    inquire(FILE=dir_name,EXIST=exist_dir)
	    if(exist_dir)then
	      write(6,*) 'Directory ',dir_name,' exists'
	    else
	      dir_name='mkdir g'//trim(group_txt)
	      write(6,*) 'Creating directory ',dir_name
	      call flush(6)
	      call system(dir_name)

! move files to that directory
             dir_name='cp * g'//trim(group_txt)//'/' 
	      call system(dir_name)
	    endif
	  enddo
	endif

	part=rank/total_members
	group=floor(part)
	key=mod(rank,total_members)
	j=1
	do i=0,size-1
	  part=i/total_members
	  group2=floor(part)
	  if(group.eq.group2)then
	    old_ranks(j)=i
	    j=j+1
	  endif
	enddo
	call MPI_Comm_group(MY_NEW_COM,old_group,ierr)
	call MPI_Group_incl(old_group,total_members,old_ranks,new_group,ierr)
	call MPI_Comm_create(MY_NEW_COM,new_group,MPI_COMM_WORLD, ierr)
	call MPI_Group_rank(new_group,rank,ierr)
	call MPI_Group_size(new_group,size,ierr)
	deallocate(old_ranks)
	call MPI_Barrier(MY_NEW_COM,ierr)

!	write(6,*) 'after barrier This is node',rank,'of',size,'I will be',key,'in group',group
!	call flush(6)
!	call MPI_Comm_split(MY_NEW_COM,group,key,MPI_COMM_WORLD,ierr)

!	call MPI_Comm_size(MPI_COMM_WORLD,size,ierr)
!	call MPI_Comm_rank(MPI_COMM_WORLD,rank,ierr)

!	write(6,*) 'Now split node',rank,'of',size,'in group',group
!	call flush(6)

	write(group_txt,'(1I0)') group
	group_txt=adjustl(group_txt)
	dir_name='g'//trim(group_txt)
	call chdir(dir_name)
	dir_name='print-'//trim(group_txt)//'.out'
	open(unit=6,file=dir_name)
	if(rank.eq.0)then
	  igroup=group+igroup
!	  write(6,*) 'Group ',group,'will do calculation',igroup
!	  call flush(6)
	  call create_run(igroup)
	endif

!	if(group.eq.0)then
	  call mpiclus(group,rank,size,MPI_COMM_WORLD,trim(group_txt))
!	endif

!	write(6,*) 'Now split node',rank,'of',size,'in group',group
!	call flush(6)
!	call MPI_Barrier(MPI_COMM_WORLD,ierr)

!	if(rank.eq.0)then
	 close(6)
!	endif

	call MPI_Comm_free(MPI_COMM_WORLD,ierr)

	call MPI_Finalize(ierr)
	end

	subroutine create_run(jgroup)
	integer :: jgroup

	
	open(2,file='RUNS')
	write(2,*) 0,jgroup
	write(2,*) 3,4
	write(2,*) 0
	close(2)
	return

	end
