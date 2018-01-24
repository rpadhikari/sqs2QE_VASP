#!/bin/bash
head -6 bestsqs.out > pos.dat
grep In bestsqs.out >> pos.dat
grep Ga bestsqs.out >> pos.dat
grep N bestsqs.out >> pos.dat
cat >sqs.f90 <<EOF
program inverse
  implicit none
  integer(4) i, j, n, m, info, lda, lwork
  parameter(n=3, m=32)
  real(8) a(n,n), c1(n,n), r(m, n), c(m, n), alat(n, n), work(n)
  real(8) a0
  integer(4) ipiv(n)
  character(2) atom(m)
  open(1,file='pos.dat', status='old',action='read')
  open(2,file='POSCAR', action='write')
  open(3,file='pwscf.in', action='write')
  read(1,*)((alat(i,j),j=1,n),i=1,n)
  read(1,*)((a(i,j),j=1,n),i=1,n)
  do i = 1, m
    read(1,*) (r(i,j),j=1,n), atom(i)
!    write(*,*) (r(i,j),j=1,n), atom(i)
  end do
  close(1)
  a0=0.529177 ! Bohr radius
  write(2,*) 'System'
  write(2,*) alat(1,1)
  write(3,*) 'celldm(1)=',alat(1,1)/a0
  c1=matmul(a,alat)
  write(3,*) 'CELL_PARAMETERS {alat}'
  do i =1,n
    write(2,101) (c1(i,j)/alat(1,1),j=1,n)
    write(3,101) (c1(i,j)/alat(1,1), j=1,n)
  end do
  write(2,*) 'In Ga  N'
  write(2,*) '14 2 16'
  write(2,*) 'Direct'
  write(3,*) 'ATOMIC_POSITIONS {crystal}'
  lda=n
  lwork=n
  call DGETRF(n, n, a, lda, ipiv, info)
  call DGETRI(n, a, lda, ipiv, work, lwork, info)
  c = matmul(r, a)
  do i = 1, m
    write(2,101)(c(i,j), j = 1,n)
    write(3,103) atom(i),(c(i,j), j = 1,n)
 !   write(*,101)(c(i,j), j = 1,n)
  end do
  write(2,*) '   '
  close(2)
  close(3)
101 format(3f15.8)
103 format(a4'  ', 3f12.8)
end program inverse
EOF
# compilation and run
gfortran sqs.f90 -llapack -lblas -o sqs.x
./sqs.x
#rm sqs.f90 sqs.x
