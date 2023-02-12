//
//  sysctl.swift
//  AppleDeveloperKit
//
//  Created by Evan Xie on 2023/2/12.
//

import Foundation

/// sysctl 是一个用来在系统运作中查看及调整系统参数的工具,它包含一些 TCP/IP 堆栈和虚拟内存系统的高级选项.
/// [About sysctl 1](https://www.tutorialspoint.com/unix_commands/sysctl.htm),
/// [About sysctl 2](https://developer.aliyun.com/article/52156)
///
/// sysctl 可以读取设置很多系统变量, 查看所有可读变量：`sysctl -a`
///
/// 基于这点，sysctl(8) 提供两个功能：读取和修改系统设置。有的 sysctl 参数只是用来回报目前的系统状况，
/// 例如回报目前已开机时间、所使用的操作系统版本、核心名称等等；而有的可以让我们修改参数以调整系统运作的行为，
/// 例如网络暂存内存的大小、最大的上线人数等等。而这些可以调整的参数中必须在一开机系统执行其它程序前就设定好，
/// 有的可以在开机完后任意调整。
public enum SystemControl {
    
    /// 常用系统变量的名字，要想查看全部，请在 Terminal 中执行 `sysctl -a` 查看.
    public enum Name: String {
        /// Int32, X86 program install on system with ARM cpu.
        case rosettaTranslated = "sysctl.proc_translated"
        
        public enum Hardware: String {
            /// String, eg: x86_64
            case machine = "hw.machine"
            
            /// String, eg: MacBookPro11,5
            case model = "hw.model"
            
            /// Int64, memory in bytes.
            case memorySize = "hw.memsize"
            
            /// Int32(cpu_type_t)
            case cpuType = "hw.cputype"
            
            /// Int32(cpu_subtype_t)
            case cpuSubtype = "hw.cpusubtype"
            
            /// Int32, the number of physical cpu cores
            case cpuPhysicalCores = "hw.physicalcpu"
            
            /// Int32, the number of logical cpu cores
            case cpuLogicalCores = "hw.logicalcpu"
            
            /// Int32, the number of cpu cores or the number of threads.
            case cpuCores = "hw.ncpu"
        }
    
    }
}

public extension SystemControl {
    
    /// 如果 ARM 程序运行在 X86 CPU 架构的计算机上，我们就说它是 被 Rosetta 转换过了。
    /// 如果 X86 程序运行在 Intel 计算机上， ARM 程序运行在 ARM 计算机上，我们就称它以 Native 的方式运行。
    static func isProcessRunningNatively() -> Bool {
        let result: Int32? = fixedWidthIntValue(byName: Name.rosettaTranslated.rawValue)
        if result == nil, errno == ENOENT {
            return true
        }
        return false
    }
    
    static func machine() -> String {
        return stringValue(byName: Name.Hardware.machine.rawValue) ?? ""
    }
    
    static func model() -> String {
        return stringValue(byName: Name.Hardware.model.rawValue) ?? ""
    }
    
    static func numberOfCPUs() -> Int32 {
        return fixedWidthIntValue(byName: Name.Hardware.cpuCores.rawValue) ?? 1
    }
    
    static func memorySize() -> Int64 {
        return fixedWidthIntValue(byName: Name.Hardware.memorySize.rawValue) ?? 0
    }
    
}

// MARK: - Universal Functions

public extension SystemControl {
    
    /// 获取结果为 int 类型
    static func fixedWidthIntValue<T>(byName name: String) -> T? where T: FixedWidthInteger {
        var result: T = 0
        var size = MemoryLayout<T>.size
        let errorCode = sysctlbyname(name, &result, &size, nil, 0)
        if errorCode != 0 {
            print("🟠 sysctlbyname(\(name)) get \(T.self) value error: \(errno)")
            return nil
        }
        return result
    }
    
    static func stringValue(byName name: String) -> String? {
        var size = 0
        
        // 0 on success, or an error code that indicates a problem occurred.
        // Possible error codes include EFAULT, EINVAL, ENOMEM, ENOTDIR, EISDIR, ENOENT, and EPERM.
        var errorCode = sysctlbyname(name, nil, &size, nil, 0)
        if errorCode != 0 {
            print("🟠 sysctlbyname(\(name)) get string count error: \(errno)")
            return nil
        }
        
        var result = [CChar](repeating: 0,  count: size)
        errorCode = sysctlbyname(name, &result, &size, nil, 0)
        if errorCode != 0 {
            print("🟠 sysctlbyname(\(name)) get string value error: \(errno)")
            return nil
        }
        
        return String(cString: result)
    }
    
}



