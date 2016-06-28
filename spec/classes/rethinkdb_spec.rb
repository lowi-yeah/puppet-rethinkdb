require 'spec_helper'

describe 'rethinkdb' do
  context 'supported operating systems' do
    ['RedHat'].each do |osfamily|
      ['CentOS'].each do |operatingsystem|
        let(:facts) {{
          :osfamily        => 'RedHat',
          :operatingsystem => 'CentOS',
        }}
        default_broker_configuration_file  = '/opt/rethinkdb/rethinkdb.conf'
        context "with explicit data (no Hiera)" do
          describe "rethinkdb with default settings on CentOS" do
            let(:params) {{ }}
            # We must mock $::operatingsystem because otherwise this test will
            # fail when you run the tests on e.g. Mac OS X.
            it { should compile.with_all_deps }

            it { should contain_class('rethinkdb::params') }
            it { should contain_class('rethinkdb') }
            it { should contain_class('rethinkdb::users').that_comes_before('rethinkdb::install') }
            it { should contain_class('rethinkdb::install').that_comes_before('rethinkdb::config') }
            it { should contain_class('rethinkdb::config') }
            it { should contain_class('rethinkdb::service').that_subscribes_to('rethinkdb::config') }

            it { should contain_package('rethinkdb').with_ensure('present') }

            it { should contain_group('rethinkdb').with({
              'ensure'     => 'present',
              'gid'        => 53076,
            })}

            it { should contain_user('rethinkdb').with({
              'ensure'     => 'present',
              'home'       => '/home/rethinkdb',
              'shell'      => '/bin/bash',
              'uid'        => 53046,
              'comment'    => 'RethinkDB system account',
              'gid'        => 'rethinkdb',
              'managehome' => true
            })}

            it { should contain_file(default_broker_configuration_file).with({
                'ensure' => 'file',
                'owner'  => 'root',
                'group'  => 'root',
                'mode'   => '0644',
              }).
              with_content(/\sdriver-port=28015\s/)
            }


            it { should_not contain_file('/tmpfs') }
            it { should_not contain_mount('/tmpfs') }

            it { should contain_supervisor__service('rethinkdb').with({
              'ensure'      => 'present',
              'enable'      => true,
              'command'     => 'rethinkdb --config-file /opt/rethinkdb/rethinkdb.conf',
              'user'        => 'rethinkuser',
              'group'       => 'rethinkgroup',
              'autorestart' => true,
              'startsecs'   => 10,
              'retries'     => 999,
              'stopsignal'  => 'INT',
              'stopasgroup' => true,
              'stopwait'    => 10,
              'stdout_logfile_maxsize' => '20MB',
              'stdout_logfile_keep'    => 5,
              'stderr_logfile_maxsize' => '20MB',
              'stderr_logfile_keep'    => 10,
            })}
          end


          describe "rethinkdb with disabled user management on #{osfamily}" do
            let(:params) {{
              :user_manage  => false,
            }}
            it { should_not contain_group('rethinkdb') }
            it { should_not contain_user('rethinkdb') }
          end

          describe "rethinkdb with custom user and group on #{osfamily}" do
            let(:params) {{
              :user_manage      => true,
              :gid              => 456,
              :group            => 'rethinkgroup',
              :uid              => 123,
              :user             => 'rethinkuser',
              :user_description => 'RethinkDB system account',
              :user_home        => '/home/rethinkuser',
            }}

            it { should_not contain_group('rethinkdb') }
            it { should_not contain_user('rethinkdb') }

            it { should contain_user('rethinkuser').with({
              'ensure'     => 'present',
              'home'       => '/home/rethinkuser',
              'shell'      => '/bin/bash',
              'uid'        => 123,
              'comment'    => 'RethinkDB system account',
              'gid'        => 'rethinkgroup',
              'managehome' => true,
            })}

            it { should contain_group('rethinkgroup').with({
              'ensure'     => 'present',
              'gid'        => 456,
            })}
          end

          describe "rethinkdb with a custom port on #{osfamily}" do
            let(:params) {{
              :driver_port => 28055,
            }}
            it { should contain_file(default_broker_configuration_file).with_content(/\driver_port=28055\s/) }
          end
        end
      end
    end
  end

  # context 'unsupported operating system' do
  #   describe 'kafka without any parameters on Debian' do
  #     let(:facts) {{
  #       :osfamily => 'Debian',
  #     }}

  #     it { expect { should contain_class('kafka') }.to raise_error(Puppet::Error,
  #       /The kafka module is not supported on a Debian based system./) }
  #   end
  # end
end
