require 'spec_helper'

describe 'Pkg::Paths' do
  describe '#arch_from_artifact_path' do
    arch_transformations = {
      ['artifacts/aix/6.1/PC1/ppc/puppet-agent-5.1.0.79.g782e03c-1.aix6.1.ppc.rpm', 'aix', '6.1'] => 'power',
      ['pkg/el-7-x86_64/puppet-agent-4.99.0-1.el7.x86_64.rpm', 'el', '7'] => 'x86_64',
      ['artifacts/ubuntu-16.04-i386/puppetserver_5.0.1-0.1SNAPSHOT.2017.07.27T2346puppetlabs1.debian.tar.gz', 'ubuntu', '16.04'] => 'source',
      ['http://saturn.puppetlabs.net/deb_repos/1234abcd/repos/apt/xenial', 'ubuntu', '16.04'] => 'amd64',
      ['pkg/ubuntu-16.04-amd64/puppet-agent_4.99.0-1xenial_amd64.deb', 'ubuntu', '16.04'] => 'amd64',
      ['artifacts/deb/jessie/PC1/puppetserver_5.0.1.master.orig.tar.gz', 'debian', '8'] => 'source',
      ['artifacts/el/6/PC1/SRPMS/puppetserver-5.0.1.master-0.1SNAPSHOT.2017.08.18T0951.el6.src.rpm', 'el', '6'] => 'SRPMS'
    }
    arch_transformations.each do |path_array, arch|
      it "should correctly return #{arch} for #{path_array[0]}" do
        expect(Pkg::Paths.arch_from_artifact_path(path_array[1], path_array[2], path_array[0])).to eq(arch)
      end
    end
  end

  describe '#tag_from_artifact_path' do
    path_tranformations = {
      'artifacts/aix/6.1/PC1/ppc/puppet-agent-5.1.0.79.g782e03c-1.aix6.1.ppc.rpm' => 'aix-6.1-power',
      'pkg/el-7-x86_64/puppet-agent-4.99.0-1.el7.x86_64.rpm' => 'el-7-x86_64',
      'pkg/ubuntu-16.04-amd64/puppet-agent_4.99.0-1xenial_amd64.deb' => 'ubuntu-16.04-amd64',
      'pkg/windows-x64/puppet-agent-4.99.0-x64.msi' => 'windows-2012-x64',
      'artifacts/el/6/products/x86_64/pe-r10k-2.5.4.3-1.el6.x86_64.rpm' => 'el-6-x86_64',
      'pkg/deb/trusty/pe-r10k_2.5.4.3-1trusty_amd64.deb' => 'ubuntu-14.04-amd64',
      'pkg/pe/rpm/el-6-i386/pe-puppetserver-2017.3.0.3-1.el6.noarch.rpm' => 'el-6-i386',
      'pkg/pe/deb/xenial/pe-puppetserver_2017.3.0.3-1puppet1_all.deb' => 'ubuntu-16.04-amd64',
      'pkg/pe/deb/xenial/super-trusty-package_1.0.0-1puppet1_all.deb' => 'ubuntu-16.04-amd64',
      'artifacts/deb/wheezy/PC1/puppetdb_4.3.1-1puppetlabs1_all.deb' => 'debian-7-amd64',
      'pkg/el/7/PC1/x86_64/puppetdb-4.3.1-1.el7.noarch.rpm' => 'el-7-x86_64',
      'pkg/apple/10.11/PC1/x86_64/puppet-agent-1.9.0-1.osx10.11.dmg' => 'osx-10.11-x86_64',
      'artifacts/mac/10.11/PC1/x86_64/puppet-agent-1.9.0-1.osx10.11.dmg' => 'osx-10.11-x86_64',
      'artifacts/eos/4/PC1/i386/puppet-agent-1.9.0-1.eos4.i386.swix' => 'eos-4-i386',
      'pkg/deb/cumulus/puppet5/puppet-agent_1.4.1.2904.g8023dd1-1cumulus_amd64.deb' => 'cumulus-2.2-amd64',
      'pkg/windows/puppet-agent-1.9.0-x86.msi' => 'windows-2012-x86',
      'artifacts/ubuntu-16.04-i386/puppetserver_5.0.1-0.1SNAPSHOT.2017.07.27T2346puppetlabs1.debian.tar.gz' => 'ubuntu-16.04-source',
      'http://saturn.puppetlabs.net/deb_repos/1234abcd/repos/apt/xenial' => 'ubuntu-16.04-amd64',
      'http://builds.puppetlabs.lan/puppet-agent/0ce4e6a0448366e01537323bbab77f834d7035c7/repos/el/6/PC1/x86_64/' => 'el-6-x86_64',
      'http://builds.puppetlabs.lan/puppet-agent/0ce4e6a0448366e01537323bbab77f834d7035c7/repos/el/6/PC1/x86_64/' => 'el-6-x86_64',
      'pkg/pe/rpm/el-6-i386/pe-puppetserver-2017.3.0.3-1.el6.src.rpm' => 'el-6-SRPMS',
      'pkg/pe/deb/xenial/pe-puppetserver_2017.3.0.3-1puppet1.orig.tar.gz' => 'ubuntu-16.04-source',
      'pkg/puppet-agent-5.1.0.79.g782e03c.gem' => nil,
      'pkg/puppet-agent-5.1.0.7.g782e03c.tar.gz' => nil,
    }
    path_tranformations.each do |pre, post|
      it "should correctly return '#{post}' when given #{pre}" do
        expect(Pkg::Paths.tag_from_artifact_path(pre)).to eq(post)
      end
    end

    failure_cases = [
      'pkg/pe/deb/preice',
      'pkg/el-4-x86_64',
      'a/package/that/sucks.rpm',
    ]
    failure_cases.each do |fail_path|
      it "should fail gracefully if given '#{fail_path}'" do
        expect { Pkg::Paths.tag_from_artifact_path(fail_path) }.to raise_error
      end
    end
  end

  describe '#repo_name' do

    it 'should return repo_name for final version' do
      allow(Pkg::Config).to receive(:repo_name).and_return('puppet5')
      expect(Pkg::Paths.repo_name).to eq('puppet5')
    end

    it 'should be empty string if repo_name is not set for final version' do
      allow(Pkg::Config).to receive(:repo_name).and_return(nil)
      expect(Pkg::Paths.repo_name).to eq('')
    end

    it 'should return nonfinal_repo_name for non-final version' do
      allow(Pkg::Config).to receive(:nonfinal_repo_name).and_return('puppet5-nightly')
      expect(Pkg::Paths.repo_name(true)).to eq('puppet5-nightly')
    end

    it 'should fail if nonfinal_repo_name is not set for non-final version' do
      allow(Pkg::Config).to receive(:repo_name).and_return('puppet5')
      allow(Pkg::Config).to receive(:nonfinal_repo_name).and_return(nil)
      expect { Pkg::Paths.repo_name(true) }.to raise_error
    end
  end

  describe '#artifacts_path' do
    before :each do
      allow(Pkg::Config).to receive(:repo_name).and_return('puppet5')
    end

    it 'should be correct for el7' do
      expect(Pkg::Paths.artifacts_path('el-7-x86_64')).to eq('artifacts/puppet5/el/7/x86_64')
    end

    it 'should be correct for trusty' do
      expect(Pkg::Paths.artifacts_path('ubuntu-14.04-amd64')).to eq('artifacts/trusty/puppet5')
    end

    it 'should be correct for solaris 11' do
      expect(Pkg::Paths.artifacts_path('solaris-11-sparc')).to eq('artifacts/solaris/puppet5/11')
    end

    it 'should be correct for osx' do
      expect(Pkg::Paths.artifacts_path('osx-10.10-x86_64')).to eq('artifacts/mac/puppet5/10.10/x86_64')
    end

    it 'should be correct for windows' do
      expect(Pkg::Paths.artifacts_path('windows-2012-x64')).to eq('artifacts/windows/puppet5')
    end

    it 'should work on all current platforms' do
      Pkg::Platforms.platform_tags.each do |tag|
        expect { Pkg::Paths.artifacts_path(tag) }.not_to raise_error
      end
    end
  end

  describe '#repo_path' do
    before :each do
      allow(Pkg::Config).to receive(:repo_name).and_return('puppet5')
    end

    it 'should be correct' do
      expect(Pkg::Paths.repo_path('el-7-x86_64')).to eq('repos/puppet5/el/7/x86_64')
    end

    it 'should work on all current platforms' do
      Pkg::Platforms.platform_tags.each do |tag|
        expect { Pkg::Paths.repo_path(tag) }.not_to raise_error
      end
    end
  end

  describe '#repo_config_path' do
    it 'should be correct' do
      expect(Pkg::Paths.repo_config_path('el-7-x86_64')).to eq('repo_configs/rpm/*el-7-x86_64*.repo')
    end

    it 'should work on all current platforms' do
      Pkg::Platforms.platform_tags.each do |tag|
        expect { Pkg::Paths.repo_config_path(tag) }.not_to raise_error
      end
    end
  end

  describe '#apt_repo_name' do
    it 'should return `Pkg::Config.repo_name` if set' do
      allow(Pkg::Config).to receive(:repo_name).and_return('puppet5')
      allow(Pkg::Config).to receive(:apt_repo_name).and_return('PC1')
      expect(Pkg::Paths.apt_repo_name).to eq('puppet5')
    end

    it 'should return `Pkg::Config.apt_repo_name` if `Pkg::Config.repo_name` is not set' do
      allow(Pkg::Config).to receive(:repo_name).and_return(nil)
      allow(Pkg::Config).to receive(:apt_repo_name).and_return('PC1')
      expect(Pkg::Paths.apt_repo_name).to eq('PC1')
    end

    it 'should return \'main\' if nothing is set' do
      allow(Pkg::Config).to receive(:repo_name).and_return(nil)
      allow(Pkg::Config).to receive(:apt_repo_name).and_return(nil)
      expect(Pkg::Paths.apt_repo_name).to eq('main')
    end
    it 'should return nonfinal_repo_name for nonfinal version' do
      allow(Pkg::Config).to receive(:repo_name).and_return('puppet5')
      allow(Pkg::Config).to receive(:nonfinal_repo_name).and_return('puppet5-nightly')
      expect(Pkg::Paths.apt_repo_name(true)).to eq('puppet5-nightly')
    end

    it 'should fail if nonfinal_repo_name is not set for non-final version' do
      allow(Pkg::Config).to receive(:repo_name).and_return('puppet5')
      allow(Pkg::Config).to receive(:nonfinal_repo_name).and_return(nil)
      expect { Pkg::Paths.apt_repo_name(true) }.to raise_error
    end
  end

  describe '#yum_repo_name' do
    it 'should return `Pkg::Config.repo_name` if set' do
      allow(Pkg::Config).to receive(:repo_name).and_return('puppet5')
      allow(Pkg::Config).to receive(:yum_repo_name).and_return('PC1')
      expect(Pkg::Paths.yum_repo_name).to eq('puppet5')
    end

    it 'should return `Pkg::Config.yum_repo_name` if `Pkg::Config.repo_name` is not set' do
      allow(Pkg::Config).to receive(:repo_name).and_return(nil)
      allow(Pkg::Config).to receive(:yum_repo_name).and_return('PC1')
      expect(Pkg::Paths.yum_repo_name).to eq('PC1')
    end

    it 'should return \'products\' if nothing is set' do
      allow(Pkg::Config).to receive(:repo_name).and_return(nil)
      allow(Pkg::Config).to receive(:yum_repo_name).and_return(nil)
      expect(Pkg::Paths.yum_repo_name).to eq('products')
    end

    it 'should return nonfinal_repo_name for nonfinal version' do
      allow(Pkg::Config).to receive(:repo_name).and_return('puppet5')
      allow(Pkg::Config).to receive(:nonfinal_repo_name).and_return('puppet5-nightly')
      expect(Pkg::Paths.yum_repo_name(true)).to eq('puppet5-nightly')
    end

    it 'should fail if nonfinal_repo_name is not set for non-final version' do
      allow(Pkg::Config).to receive(:repo_name).and_return('puppet5')
      allow(Pkg::Config).to receive(:nonfinal_repo_name).and_return(nil)
      expect { Pkg::Paths.yum_repo_name(true) }.to raise_error
    end
  end

  describe '#is_legacy_repo?' do
    it 'returns true for empty strings' do
      expect(Pkg::Paths.is_legacy_repo?('')).to be_true
    end

    it 'returns true for PC1' do
      expect(Pkg::Paths.is_legacy_repo?('PC1')).to be_true
    end

    it 'returns true for foopuppetbar' do
      expect(Pkg::Paths.is_legacy_repo?('foopuppetbar')).to be_true
    end

    it 'returns false for puppet5' do
      expect(Pkg::Paths.is_legacy_repo?('puppet5')).to be_false
    end

    it 'returns false for puppet8-nightly' do
      expect(Pkg::Paths.is_legacy_repo?('puppet8-nightly')).to be_false
    end

    it 'returns false for puppet' do
      expect(Pkg::Paths.is_legacy_repo?('puppet')).to be_false
    end
  end
end
