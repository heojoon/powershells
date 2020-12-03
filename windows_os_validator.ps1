#
# 윈도우 기본 설정 구성 수행 스크립트 v0.1
#
# 실행 환경 : Windows 2016
# Powershell (관리자모드)
#

# 시스템 정보
systeminfo

# 키보드 덤프키 설정
Write-Output "##### 키보드 덤프키 설정 #####"
REG ADD HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\i8042prt\Parameters /v CrashOnCtrlScroll /t REG_DWORD /d 1

# NMI 덤프 설정값
Write-Output "##### NMI 덤프 설정값 #####"
REG ADD HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\CrashControl /v NMICrashDump /t REG_DWORD /d 1

# NTP 서버 설정 타입 확인 ( NT5DS : AD Join , Workgroup : NTP )
Write-Output "##### NTP 서버 설정 타입 확인 ( NT5DS : AD Join , Workgroup : NTP ) #####"
reg query HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\w32Time\Parameters | findstr Type

# NTP 서버와 시간 동기화
Write-Output "##### NTP 서버와 시간 동기화 #####"
w32tm /config /syncfromflags:domhier /reliable:no /update 
net stop w32time 
net start w32time

# NTP 시간 Offset 확인
# AD Joined 서버 : 0xffffffff , 0xffffffff  정상
# AD 미조인 서버 or DC (AD서버) : 900 으로 변경 필요.
Write-Output "##### NTP 시간 Offset 확인  #####"
reg query HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\Config | findstr MaxPosPhaseCorrection
reg query HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\Config | findstr MaxNegPhaseCorrection

# CPU 절전모드 확인
# 비정상 : CurrentClockSpeed가 MaxClockSpeed보다 낮은 경우 
# 해결 : BIOS → 전원옵션 → CPU → P-Status 비활성화
Write-Output "##### CPU 클럭 스피드/최대스피드 확인 #####"
wmic cpu get currentclockspeed,maxclockspeed

# CPU 절전모드 확인
# 전원 구성 설정 변경 : 고성능
Write-Output "##### CPU 절전모드 확인 #####"
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
powercfg -l

# 메모리 모듈별 용량
# 나오는 값이 동일하면 정상
Write-Output "##### 메모리 모듈별 용량 #####"
wmic memorychip get capacity

# 메모리 모듈별 속도
# 나오는 값이 동일하면 정상
Write-Output "##### 메모리 모듈별 속도 #####"
wmic memorychip get speed

# 가상메모리(페이징) 자동관리 False 설정
Write-Output "##### 가상메모리(페이징) 자동관리 False 설정 #####"
Write-Output "가상메모리 설정 : 16384"
wmic computersystem where "name='$(hostname)'" set AutomaticManagedPagefile=False
wmic pagefileset where "name='C:\\pagefile.sys'" set InitialSize=16384,MaximumSize=16384

# 보안 로그 정리
Write-Output "##### 보안 로그 정리 및 저장주기 변경 (로그 미삭제)  #####"
Clear-Eventlog Security
Get-Eventlog Security

# 보안로그 저장 주기 
#  -> 로테이트 하지 않음 , 필요시 별도 저장 ( 기술진단 파트 가이드 )
reg ADD HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Eventlog\Security /f /v Retention  /t REG_DWORD /d 0xffffffff
reg ADD HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Eventlog\Security /f /v AutoBackupLogFiles /t REG_DWORD /d 0

# 네트워크 어댑터 바인딩 
# 정상: 네트워크 바인딩 순위가 점검기준에 맞게 설정됨 
# 취약: 네트워크 바인딩 순위가 점검기준에 맞게 설정되지 않음 
# 네트워크 매트릭 수정
Write-Output "##### 네트웤 어댑터 매트릭 수정 (서비스 NIC 상위로 변경) #####"
$SvcNIC = "Team#1"
netsh interface ipv4 show config
netsh interface ipv4 show interface
netsh interface ipv4 set interface "$SvcNIC" metric=1
netsh interface ipv4 show interface
