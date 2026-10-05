import { registerAs } from '@nestjs/config';
import { TypeOrmModuleOptions } from '@nestjs/typeorm';

export const getDatabaseConfig = (): TypeOrmModuleOptions => {
  const baseConfig: TypeOrmModuleOptions = {
    type: 'mysql',
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '3306', 10),
    username: process.env.DB_USER || process.env.MYSQL_USER || 'draw_user',
    password:
      process.env.DB_PASSWORD || process.env.MYSQL_PASSWORD || 'draw_password',
    database:
      process.env.DB_NAME || process.env.MYSQL_DATABASE || 'draw_class_db',
    entities: [__dirname + '/../**/*.entity{.ts,.js}'],
    autoLoadEntities: true,
    synchronize: process.env.NODE_ENV !== 'production',
    logging: process.env.NODE_ENV !== 'production',
  };

  if (process.env.DATABASE_URL) {
    return {
      ...baseConfig,
      url: process.env.DATABASE_URL,
    };
  }

  return baseConfig;
};

export default registerAs('database', getDatabaseConfig);
