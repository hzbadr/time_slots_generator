require 'date'
require 'json'

class SlotsGenerator

  def self.call
    driver_ids = (1..10)
    company_ids = (1..10).to_a

    start_time = DateTime.now.prev_day(10)
    end_time = DateTime.now

    SlotsGenerator.new(driver_ids, company_ids, start_time, end_time).call
  end

  def initialize(driver_ids, company_ids, start_time, end_time)
    @slots = (start_time..end_time).map do |time|
      driver_ids.map do |driver_id|
        generate_daily_activity_for_driver(driver_id, company_ids.sample, fields, time.to_time.to_i)
      end
    end.flatten
  end

  def call
    write_to_file("#{ENV['HOME']}/Desktop/slots.json", JSON.generate(@slots))
    write_to_file("#{ENV['HOME']}/Desktop/fields.json", JSON.generate(fields))
  end

  private
  def write_to_file(file_path, date)
    File.open(file_path, 'w') { |file| file.write(date) }
  end

  def generate_daily_activity_for_driver(driver_id, company_id, fields, time)
    slots = []

    slots += generate_repairing(driver_id, company_id, fields.sample, time, 60)
    slots += generate_cultivating(driver_id, company_id, fields.sample, time + (60 * 70), 180)
    slots + generate_driving(driver_id, company_id, time + (60 * 250), 90)
  end

  def generate_repairing(driver_id, company_id, field, start_time, duration_in_minutes)
    lat = field.first.first
    long = field.first.last

    start_time = start_time.to_i
    end_time = start_time + duration_in_minutes * 60

    (start_time..end_time).step(2).map do |timestamp|
      {
        company_id: company_id,
        driver_id: driver_id,
        timestamp: timestamp,
        latitude: lat,
        longitude:long,
        accuracy:12.0,
        speed: 1
      }
    end
  end

  def generate_cultivating(driver_id, company_id, field, start_time, duration_in_minutes)
    lat = field.last.first
    long = field.last.last
    start_time = start_time.to_i
    end_time = start_time + duration_in_minutes * 60

    (start_time..end_time).step(2).map do |timestamp|
      {
        company_id: company_id,
        driver_id:driver_id,
        timestamp: timestamp,
        latitude: lat,
        longitude:long,
        accuracy:12.0,
        speed: 2
      }
    end
  end

  def generate_driving(driver_id, company_id, start_time, duration_in_minutes)
    start_time = start_time.to_i
    end_time = start_time + duration_in_minutes * 60

    (start_time..end_time).step(2).map do |timestamp|
      {
        company_id: company_id,
        driver_id: driver_id,
        timestamp: timestamp,
        latitude: 80,
        longitude:90,
        accuracy:12.0,
        speed: 6
      }
    end
  end

  def fields
    vertix1 = [1, 2, 3, 4].zip([5, 6, 7, 8])
    vertix2 = [7, 9, 10, 11].zip([20, 21, 22, 23])
    vertix3 = [15, 17, 18, 19].zip([25, 27, 29, 30])

    [vertix1, vertix2, vertix3]
  end
end

puts "Generating slots .."
SlotsGenerator.call
puts "Done!"