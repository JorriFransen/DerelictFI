/*

Boost Software License - Version 1.0 - August 17th, 2003

Permission is hereby granted, free of charge, to any person or organization
obtaining a copy of the software and accompanying documentation covered by
this license (the "Software") to use, reproduce, display, distribute,
execute, and transmit the Software, and to prepare derivative works of the
Software, and to permit third-parties to whom the Software is furnished to
do so, all subject to the following:

The copyright notices in the Software and this entire statement, including
the above license grant, this restriction and the following disclaimer,
must be included in all copies of the Software, in whole or in part, and
all derivative works of the Software, unless such copies or derivative
works are solely in the form of machine-executable object code generated by
a source language processor.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.

*/
module derelict.freeimage.freeimage;

import derelict.util.exception,
       derelict.util.system;

public
import derelict.freeimage.functions,
       derelict.freeimage.types,
       derelict.util.loader;

class DerelictFILoader : SharedLibLoader
{
    this() { super(libNames); }

protected:
    override void configureMinimumVersion(SharedLibVersion minVersion)
    {
        if(minVersion.major == 3) {
            if(minVersion.minor == 15) {
                if(minVersion.patch == 4)
                    missingSymbolCallback = &allowFI_3_15_4;
                else
                    missingSymbolCallback = &allowFI_3_15_0;
            }
            else if(minVersion.minor == 16)
                missingSymbolCallback = &allowFI_3_16_0;
        }
    }

    override void loadSymbols() { loadFuncs(this); }

private:
    ShouldThrow allowFI_3_15_0(string symbolName)
    {
        static if(Derelict_OS_Windows && !Derelict_Arch_64) {
            if(symbolName == "_FreeImage_ConvertToRGB16@4")
                return ShouldThrow.No;
        }
        else {
            if(symbolName == "FreeImage_ConvertToRGB16")
                return ShouldThrow.No;
        }
        return allowFI_3_15_4(symbolName);
    }

    ShouldThrow allowFI_3_15_4(string symbolName)
    {
        switch(symbolName) {
            static if(Derelict_OS_Windows && !Derelict_Arch_64) {
                case "_FreeImage_JPEGTransformFromHandle@40":
                case "_FreeImage_JPEGTransformCombined@32":
                case "_FreeImage_JPEGTransformCombinedU@32":
                case "_FreeImage_JPEGTransformCombinedFromMemory@32":
                    return ShouldThrow.No;
            }
            else {
                case "FreeImage_JPEGTransformFromHandle":
                case "FreeImage_JPEGTransformCombined":
                case "FreeImage_JPEGTransformCombinedU":
                case "FreeImage_JPEGTransformCombinedFromMemory":
                    return ShouldThrow.No;
            }
            default: return allowFI_3_16_0(symbolName);
        }
    }

    ShouldThrow allowFI_3_16_0(string symbolName)
    {
        switch(symbolName) {
            static if(Derelict_OS_Windows && !Derelict_Arch_64) {
                case "_FreeImage_GetMemorySize@4":
                case "_FreeImage_ConvertFromRawBitsEx@44":
                case "_FreeImage_ConvertToRGBAF@4":
                case "_FreeImage_ConvertToRGBA16@4":
                case "_FreeImage_SetMetadataKeyValue@16":
                case "_FreeImage_RescaleRect@36":
                case "_FreeImage_CreateView@20":
                    return ShouldThrow.No;
            }
            else {
                case "FreeImage_GetMemorySize":
                case "FreeImage_ConvertFromRawBitsEx":
                case "FreeImage_ConvertToRGBAF":
                case "FreeImage_ConvertToRGBA16":
                case "FreeImage_SetMetadataKeyValue":
                case "FreeImage_RescaleRect":
                case "FreeImage_CreateView":
                    return ShouldThrow.No;
            }
            default: return ShouldThrow.Yes;
        }
    }
}

__gshared DerelictFILoader DerelictFI;

shared static this()
{
    DerelictFI = new DerelictFILoader();
}

private:
    static if(Derelict_OS_Windows)
        enum libNames = "FreeImage.dll";
    else static if(Derelict_OS_Mac)
        enum libNames = "libfreeimage.dylib,libfreeimage.dylib.3";
    else static if(Derelict_OS_Posix)
        enum libNames = "libfreeimage.so,libfreeimage.so.3";
    else
        static assert(0, "Need to implement FreeImage libNames for this operating system.");
