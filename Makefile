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

include $(topsrcdir)mono/config.make

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

install:
	-rm -fr $(DESTDIR)$(monodir)/fsharp
	-rm -fr $(DESTDIR)$(monodir)/Microsoft\ F#
	-rm -fr $(DESTDIR)$(monodir)/Microsoft\ SDKs/F#
	-rm -fr $(DESTDIR)$(monodir)/msbuild/Microsoft/VisualStudio/v/FSharp
	-rm -fr $(DESTDIR)$(monodir)/msbuild/Microsoft/VisualStudio/v11.0/FSharp
	-rm -fr $(DESTDIR)$(monodir)/msbuild/Microsoft/VisualStudio/v12.0/FSharp
	-rm -fr $(DESTDIR)$(monodir)/msbuild/Microsoft/VisualStudio/v14.0/FSharp
	-rm -fr $(DESTDIR)$(monodir)/msbuild/Microsoft/VisualStudio/v15.0/FSharp
	$(MAKE) -C mono/FSharp.Core TargetDotnetProfile=net45 install
	$(MAKE) -C mono/FSharp.Build install
	$(MAKE) -C mono/FSharp.Compiler.Private install
	$(MAKE) -C mono/Fsc install
	$(MAKE) -C mono/FSharp.Compiler.Interactive.Settings install
	$(MAKE) -C mono/FSharp.Compiler.Server.Shared install
	$(MAKE) -C mono/fsi install
	$(MAKE) -C mono/fsiAnyCpu install
	$(MAKE) -C mono/FSharp.Core TargetDotnetProfile=net40 FSharpCoreBackVersion=3.0 install
	$(MAKE) -C mono/FSharp.Core TargetDotnetProfile=net40 FSharpCoreBackVersion=3.1 install
	$(MAKE) -C mono/FSharp.Core TargetDotnetProfile=net40 FSharpCoreBackVersion=4.0 install
	$(MAKE) -C mono/FSharp.Core TargetDotnetProfile=net40 FSharpCoreBackVersion=4.1 install
	$(MAKE) -C mono/FSharp.Core TargetDotnetProfile=portable47 install
	$(MAKE) -C mono/FSharp.Core TargetDotnetProfile=portable7 install
	$(MAKE) -C mono/FSharp.Core TargetDotnetProfile=portable78 install
	$(MAKE) -C mono/FSharp.Core TargetDotnetProfile=portable259 install
	$(MAKE) -C mono/FSharp.Core TargetDotnetProfile=monoandroid10+monotouch10+xamarinios10 install
	$(MAKE) -C mono/FSharp.Core TargetDotnetProfile=xamarinmacmobile install
	echo "------------------------------ INSTALLED FILES --------------"
	ls -xlR $(DESTDIR)$(monodir)/fsharp $(DESTDIR)$(monodir)/msbuild $(DESTDIR)$(monodir)/xbuild $(DESTDIR)$(monodir)/Reference\ Assemblies $(DESTDIR)$(monodir)/gac/FSharp* $(DESTDIR)$(monodir)/Microsoft* || true

