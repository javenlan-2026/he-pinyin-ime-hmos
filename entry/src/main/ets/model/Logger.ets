/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { hilog } from '@kit.PerformanceAnalysisKit';

const LOGGER_DOMAIN: number = 0xFF00;
const TAG: string = 'HePinyinIME';

class Logger {
  static info(msg: string, ...args: any[]): void {
    hilog.info(LOGGER_DOMAIN, TAG, msg, args);
  }

  static error(msg: string, ...args: any[]): void {
    hilog.error(LOGGER_DOMAIN, TAG, msg, args);
  }

  static debug(msg: string, ...args: any[]): void {
    hilog.debug(LOGGER_DOMAIN, TAG, msg, args);
  }
}

export default Logger;