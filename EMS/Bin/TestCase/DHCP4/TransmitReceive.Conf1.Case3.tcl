#
# The material contained herein is not a license, either      
# expressly or impliedly, to any intellectual property owned  
# or controlled by any of the authors or developers of this   
# material or to any contribution thereto. The material       
# contained herein is provided on an "AS IS" basis and, to the
# maximum extent permitted by applicable law, this information
# is provided AS IS AND WITH ALL FAULTS, and the authors and  
# developers of this material hereby disclaim all other       
# warranties and conditions, either express, implied or       
# statutory, including, but not limited to, any (if any)      
# implied warranties, duties or conditions of merchantability,
# of fitness for a particular purpose, of accuracy or         
# completeness of responses, of results, of workmanlike       
# effort, of lack of viruses and of lack of negligence, all   
# with regard to this material and any contribution thereto.  
# Designers must not rely on the absence or characteristics of
# any features or instructions marked "reserved" or           
# "undefined." The Unified EFI Forum, Inc. reserves any       
# features or instructions so marked for future definition and
# shall have no responsibility whatsoever for conflicts or    
# incompatibilities arising from future changes to them. ALSO,
# THERE IS NO WARRANTY OR CONDITION OF TITLE, QUIET ENJOYMENT,
# QUIET POSSESSION, CORRESPONDENCE TO DESCRIPTION OR          
# NON-INFRINGEMENT WITH REGARD TO THE TEST SUITE AND ANY      
# CONTRIBUTION THERETO.                                       
#                                                             
# IN NO EVENT WILL ANY AUTHOR OR DEVELOPER OF THIS MATERIAL OR
# ANY CONTRIBUTION THERETO BE LIABLE TO ANY OTHER PARTY FOR   
# THE COST OF PROCURING SUBSTITUTE GOODS OR SERVICES, LOST    
# PROFITS, LOSS OF USE, LOSS OF DATA, OR ANY INCIDENTAL,      
# CONSEQUENTIAL, DIRECT, INDIRECT, OR SPECIAL DAMAGES WHETHER 
# UNDER CONTRACT, TORT, WARRANTY, OR OTHERWISE, ARISING IN ANY
# WAY OUT OF THIS OR ANY OTHER AGREEMENT RELATING TO THIS     
# DOCUMENT, WHETHER OR NOT SUCH PARTY HAD ADVANCE NOTICE OF   
# THE POSSIBILITY OF SUCH DAMAGES.                            
#                                                             
# Copyright 2006, 2007, 2008, 2009, 2010 Unified EFI, Inc. All
# Rights Reserved, subject to all existing rights in all      
# matters included within this Test Suite, to which United    
# EFI, Inc. makes no claim of right.                          
#                                                             
# Copyright (c) 2010, Intel Corporation. All rights reserved.<BR> 
#
#
################################################################################
CaseLevel         CONFORMANCE
CaseAttribute     AUTO
CaseVerboseLevel  DEFAULT
set reportfile    report.csv

#
# test case Name, category, description, GUID...
#
CaseGuid        b393e6ae-282a-47b6-9969-26c03044210e
CaseName        TransmitReceive.Conf1.Case3
CaseCategory    DHCP4
CaseDescription {This case is to test the Conformance - EFI_INVALID_PARAMETER  \
                -- Packet is not a well-formed DHCP packet- Magic Number error.}

################################################################################

Include DHCP4/include/Dhcp4.inc.tcl

proc CleanUpEutEnvironment {} {
  Dhcp4ServiceBinding->DestroyChild "@R_Handle, &@R_Status"
  GetAck

  EndScope _DHCP4_TRANSMITRECEIVE_CONF1
  EndLog
}

#
# Begin log ...
#
BeginLog

#
# BeginScope
#
BeginScope _DHCP4_TRANSMITRECEIVE_CONF1

#
# Parameter Definition
# R_ represents "Remote EFI Side Parameter"
# L_ represents "Local ENTS Side Parameter"
#
UINTN                               R_Status
UINTN                               R_Handle

EFI_DHCP4_TRANSMIT_RECEIVE_TOKEN    R_Token
EFI_DHCP4_LISTEN_POINT              R_ListenPoint
EFI_DHCP4_PACKET                    R_Packet

#
# Call [DHCP4SBP] -> CreateChild to create child.
#
Dhcp4ServiceBinding->CreateChild {&@R_Handle, &@R_Status}
GetAck
set assert [VerifyReturnStatus R_Status $EFI_SUCCESS]
RecordAssertion $assert $GenericAssertionGuid                                  \
                "Dhcp4SBP.CreateChild - Create Child 1"                        \
                "ReturnStatus - $R_Status, ExpectedStatus - $EFI_SUCCESS"
SetVar     [subst $ENTS_CUR_CHILD]  @R_Handle

#
# Call [DHCP4] -> TransmitReceive with the invalid parameters
# o	Packet is not a well-formed DHCP packet - Magic Number error.
#
SetVar  R_Packet.Size                     [expr [Sizeof EFI_DHCP4_HEADER]]
SetVar  R_Packet.Length                   [expr [Sizeof EFI_DHCP4_HEADER] + 5]
SetVar  R_Packet.Dhcp4.Magik              0x11111111
SetVar  R_Packet.Dhcp4.Header.OpCode      1
SetVar  R_Packet.Dhcp4.Header.HwType      1
SetVar  R_Packet.Dhcp4.Header.HwAddrLen   6
SetVar  R_Packet.Dhcp4.Header.Xid         0xe139e46c
SetIpv4Address  R_Packet.Dhcp4.Header.ClientAddr    "192.168.11.21"
SetVar  R_Packet.Dhcp4.Header.ClientHwAddr  { 0x00 0x0d 0x60 0x36 0x87 0x49}
SetVar  R_Packet.Dhcp4.Option               {0xff}

SetIpv4Address  R_ListenPoint.ListenAddress   "0.0.0.0"
SetIpv4Address  R_ListenPoint.SubnetMask      "255.255.255.255"
SetVar          R_ListenPoint.ListenPort      68

SetVar          R_Token.Status                0
SetVar          R_Token.CompletionEvent       0
SetIpv4Address  R_Token.RemoteAddress         "192.168.1.34" 
SetVar          R_Token.RemotePort            0
SetVar          R_Token.ListenPointCount      1
SetVar          R_Token.ListenPoints          &@R_ListenPoint
SetVar          R_Token.TimeoutValue          10;   #TimeoutValue is 10s
SetVar          R_Token.Packet                &@R_Packet

#
# Check Point: Call Dhcp4.TransmitReceive while packet is not a well-formed 
#              DHCP packet(Magic Number error).
#
Dhcp4->TransmitReceive "&@R_Token, &@R_Status"
GetAck
set assert [VerifyReturnStatus R_Status $EFI_INVALID_PARAMETER]
RecordAssertion $assert $Dhcp4TransmitReceiveConf1AssertionGuid003             \
                "Dhcp4.TransmitReceive - Conf - not a well-formed DHCP packet( \
                Magic Number error)."                                          \
                "ReturnStatus - $R_Status, ExpectedStatus -                    \
                $EFI_INVALID_PARAMETER"

#
# Clean up the environment on EUT side.
#
CleanUpEutEnvironment
