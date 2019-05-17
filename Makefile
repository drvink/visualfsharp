Configuration ?= release
Verbosity ?= normal
VerbosityProperty = /Verbosity:$(Verbosity)
MSBuild = msbuild
RestoreCommand = $(MSBuild) /t:Restore
BuildCommand = $(MSBuild) /t:Build
TestCommand = $(MSBuild) /t:Test
ProtoConfiguration = /p:Configuration=Proto
ConfigurationProperty = /p:Configuration=$(Configuration)

NF45 = /p:TargetFramework=net45
NF472 = /p:TargetFramework=net472
NS16 = /p:TargetFramework=netstandard1.6
NS20 = /p:TargetFramework=netstandard2.0
NCA20 = /p:TargetFramework=netcoreapp2.0
NCA21 = /p:TargetFramework=netcoreapp2.1

all: proto restore build

proto:
	$(RestoreCommand) src/buildtools/buildtools.proj 
	$(RestoreCommand) src/fsharp/FSharp.Build/FSharp.Build.fsproj 
	$(RestoreCommand) src/fsharp/fsc/fsc.fsproj 
	$(BuildCommand) $(ProtoConfiguration) src/buildtools/buildtools.proj 
	$(BuildCommand) $(NF472) $(ProtoConfiguration) $(VerbosityProperty) src/fsharp/FSharp.Build/FSharp.Build.fsproj
	$(BuildCommand) $(NF472) $(ProtoConfiguration) src/fsharp/fsc/fsc.fsproj

restore:
	$(RestoreCommand) src/fsharp/FSharp.Core/FSharp.Core.fsproj
	$(RestoreCommand) src/fsharp/FSharp.Build/FSharp.Build.fsproj
	$(RestoreCommand) src/fsharp/FSharp.Compiler.Private/FSharp.Compiler.Private.fsproj
	$(RestoreCommand) src/fsharp/fsc/fsc.fsproj
	$(RestoreCommand) src/fsharp/FSharp.Compiler.Interactive.Settings/FSharp.Compiler.Interactive.Settings.fsproj
	$(RestoreCommand) src/fsharp/fsi/fsi.fsproj
	$(RestoreCommand) tests/FSharp.Core.UnitTests/FSharp.Core.UnitTests.fsproj
	$(RestoreCommand) tests/FSharp.Build.UnitTests/FSharp.Build.UnitTests.fsproj

build: proto restore
	$(BuildCommand) $(ConfigurationProperty) $(NF45) src/fsharp/FSharp.Core/FSharp.Core.fsproj
	$(BuildCommand) $(ConfigurationProperty) $(NF472) src/fsharp/FSharp.Build/FSharp.Build.fsproj
	$(BuildCommand) $(ConfigurationProperty) $(NF472) src/fsharp/FSharp.Compiler.Private/FSharp.Compiler.Private.fsproj
	$(BuildCommand) $(ConfigurationProperty) $(NF472) src/fsharp/fsc/fsc.fsproj
	$(BuildCommand) $(ConfigurationProperty) $(NF472) src/fsharp/FSharp.Compiler.Interactive.Settings/FSharp.Compiler.Interactive.Settings.fsproj
	$(BuildCommand) $(ConfigurationProperty) $(NF472) src/fsharp/fsi/fsi.fsproj
	$(BuildCommand) $(ConfigurationProperty) $(NF472) tests/FSharp.Core.UnitTests/FSharp.Core.UnitTests.fsproj
	$(BuildCommand) $(ConfigurationProperty) $(NF472) tests/FSharp.Build.UnitTests/FSharp.Build.UnitTests.fsproj

test: build
	$(TestCommand) $(NF472) $(ConfigurationProperty) --no-restore --no-build tests/FSharp.Core.UnitTests/FSharp.Core.UnitTests.fsproj -l "trx;LogFileName=$(CURDIR)/tests/TestResults/FSharp.Core.UnitTests.coreclr.trx"
	$(TestCommand) $(NF472) $(ConfigurationProperty) --no-restore --no-build tests/FSharp.Build.UnitTests/FSharp.Build.UnitTests.fsproj -l "trx;LogFileName=$(CURDIR)/tests/TestResults/FSharp.Build.UnitTests.coreclr.trx"

clean:
	rm -rf $(CURDIR)/artifacts
