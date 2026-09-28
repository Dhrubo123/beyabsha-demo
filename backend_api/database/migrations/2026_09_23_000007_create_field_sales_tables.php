<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
return new class extends Migration {
 public function up(): void {
  Schema::create('salesperson_profiles',function(Blueprint $t){$t->id();$t->foreignId('user_id')->unique()->constrained()->cascadeOnDelete();$t->foreignId('branch_id')->constrained()->cascadeOnDelete();$t->decimal('daily_target',14,2)->default(0);$t->boolean('is_active')->default(true);$t->timestamps();});
  Schema::create('attendances',function(Blueprint $t){$t->id();$t->foreignId('user_id')->constrained()->cascadeOnDelete();$t->foreignId('branch_id')->constrained()->cascadeOnDelete();$t->date('attendance_date');$t->timestamp('check_in_at')->nullable();$t->timestamp('check_out_at')->nullable();$t->decimal('check_in_latitude',10,7)->nullable();$t->decimal('check_in_longitude',10,7)->nullable();$t->timestamps();$t->unique(['user_id','attendance_date']);});
  Schema::create('sales_routes',function(Blueprint $t){$t->id();$t->foreignId('business_id')->constrained()->cascadeOnDelete();$t->foreignId('branch_id')->constrained()->cascadeOnDelete();$t->foreignId('salesperson_id')->constrained('users')->cascadeOnDelete();$t->date('route_date');$t->string('name')->nullable();$t->string('status')->default('planned');$t->timestamps();});
  Schema::create('route_visits',function(Blueprint $t){$t->id();$t->foreignId('sales_route_id')->constrained()->cascadeOnDelete();$t->foreignId('customer_id')->constrained()->restrictOnDelete();$t->unsignedInteger('sequence');$t->time('scheduled_time')->nullable();$t->string('status')->default('pending');$t->timestamp('checked_in_at')->nullable();$t->timestamp('checked_out_at')->nullable();$t->decimal('latitude',10,7)->nullable();$t->decimal('longitude',10,7)->nullable();$t->text('notes')->nullable();$t->timestamps();$t->unique(['sales_route_id','sequence']);});
 }
 public function down(): void {Schema::dropIfExists('route_visits');Schema::dropIfExists('sales_routes');Schema::dropIfExists('attendances');Schema::dropIfExists('salesperson_profiles');}
};
