class EnablePgcryptoExtension < ActiveRecord::Migration
  def change
    enable_extension 'pgcrypto'
    enable_extension 'uuid-ossp'
  end
end
