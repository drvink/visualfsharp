Configuration ?= Release
ConfigurationProperty = /p:Configuration=$(Configuration)

Verbosity ?= normal
VerbosityProperty = /Verbosity:$(Verbosity)

MSBuild = $(shell which msbuild)
RestoreCommand = $(MSBuild) /t:Restore
BuildCommand = $(MSBuild) /t:Build
TestCommand = $(MSBuild) /t:VSTest
ProtoConfiguration = /p:Configuration=Proto

NF45 = /p:TargetFramework=net45
NF472 = /p:TargetFramework=net472
NS16 = /p:TargetFramework=netstandard1.6
NS20 = /p:TargetFramework=netstandard2.0
NCA20 = /p:TargetFramework=netcoreapp2.0
NCA21 = /p:TargetFramework=netcoreapp2.1

all: proto restore build

proto:
	$(RestoreCommand) $(NF472) src/buildtools/buildtools.proj 
	$(RestoreCommand) $(NF472) src/fsharp/FSharp.Build/FSharp.Build.fsproj 
	$(RestoreCommand) $(NF472) src/fsharp/fsc/fsc.fsproj
	$(BuildCommand) $(NF472) $(ConfigurationProperty) src/buildtools/buildtools.proj 
	$(BuildCommand) $(NF472) $(ProtoConfiguration) src/fsharp/FSharp.Build/FSharp.Build.fsproj
	$(BuildCommand) $(NF472) $(ProtoConfiguration) $(VerbosityProperty) src/fsharp/fsc/fsc.fsproj

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

# note: can only run the VsTest target on dotnet sdk preview 3 or better, so right now this won't work on mono 5.20.
# todo: replace with nunit invocation directly for mono builds?
test: build
	$(TestCommand) $(NF472) $(ConfigurationProperty) tests/FSharp.Core.UnitTests/FSharp.Core.UnitTests.fsproj /p:VSTestNoBuild=true /p:VSTestLogger="trx;LogFileName=$(CURDIR)/tests/TestResults/FSharp.Core.UnitTests.coreclr.trx"
	$(TestCommand) $(NF472) $(ConfigurationProperty) tests/FSharp.Build.UnitTests/FSharp.Build.UnitTests.fsproj /p:VSTestNoBuild=true /p:VSTestLogger="trx;LogFileName=$(CURDIR)/tests/TestResults/FSharp.Build.UnitTests.coreclr.trx"

clean:
	rm -rf $(CURDIR)/Artifacts
