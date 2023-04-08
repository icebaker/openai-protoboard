class Presenter {
  static shortMoney(userValue, currency) {
    if (userValue === undefined || userValue === null) return '-';

    const symbol = currency === 'BRL' ? 'R$ ' : '';
    const locale = currency === 'BRL' ? 'pt-br' : 'en-us';

    const value = userValue;

    if (value > 500000000000 || value < -500000000000) {
      return `${symbol}${(value / 1000000000000).toLocaleString(locale, {
        maximumFractionDigits: 1
      })}T`;
    }

    if (value > 500000000 || value < -500000000) {
      return `${symbol}${(value / 1000000000).toLocaleString(locale, {
        maximumFractionDigits: 1
      })}b`;
    }

    if (value > 500000 || value < -500000) {
      return `${symbol}${(value / 1000000).toLocaleString(locale, { maximumFractionDigits: 1 })}MM`;
    }

    if (value > 50000 || value < -50000) {
      return `${symbol}${(value / 1000).toLocaleString(locale, { maximumFractionDigits: 0 })}k`;
    }

    if (value > 500 || value < -500) {
      return `${symbol}${(value / 1000).toLocaleString(locale, { maximumFractionDigits: 1 })}k`;
    }

    if (value.toLocaleString(locale, { maximumFractionDigits: 2 }) === '-0') {
      return `${symbol}0`;
    }

    if (value.toLocaleString(locale, { maximumFractionDigits: 1 }) === '-0') {
      return `${symbol}${value.toLocaleString(locale, { maximumFractionDigits: 2 })}`;
    }

    if (value.toLocaleString(locale, { maximumFractionDigits: 0 }) === '-0') {
      return `${symbol}${value.toLocaleString(locale, { maximumFractionDigits: 1 })}`;
    }

    if (value < 10 && value > 0) {
      return `${symbol}${value.toLocaleString(locale, { maximumFractionDigits: 2 })}`;
    }

    return `${symbol}${value.toLocaleString(locale, { maximumFractionDigits: 0 })}`;
  }

  static dateTime(rawISO) {
    if (rawISO === undefined) return '-';

    const dateTime = new Date(rawISO);
    const date = dateTime.toLocaleDateString({
      weekday: 'long',
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    });
    const time = dateTime.toLocaleTimeString();
    return `${date} - ${time}`;
  }

  static time(rawISO) {
    if (rawISO === undefined) return '-';

    const dateTime = new Date(rawISO);
    return dateTime.toLocaleTimeString();
  }

  static number(value, min, max) {
    if (value === undefined) return '-';
    const locale = 'en-us';

    if (min === undefined) min = 0;
    if (max === undefined) max = 0;

    return `${value.toLocaleString(locale, {
      minimumFractionDigits: min,
      maximumFractionDigits: max
    })}`;
  }

  static money(value, currency, max) {
    const symbol = currency === 'BRL' ? 'R$ ' : '$';
    const locale = currency === 'BRL' ? 'pt-br' : 'en-us';

    if (max === undefined) max = 2;

    return `${symbol}${value.toLocaleString(locale, {
      minimumFractionDigits: 2,
      maximumFractionDigits: max
    })}`;
  }

  static percent(value, userMinDigits, userMaxDigits) {
    let minDigits = 2;
    let maxDigits = 2;

    if (userMinDigits !== undefined) minDigits = userMinDigits;
    if (userMaxDigits !== undefined) maxDigits = userMaxDigits;

    return `${(value * 100.0).toLocaleString('en-us', {
      minimumFractionDigits: minDigits,
      maximumFractionDigits: maxDigits
    })}%`;
  }

  static percentPrecise(value) {
    return `${(value * 100.0).toLocaleString('en-us', {
      minimumFractionDigits: 0,
      maximumFractionDigits: 5
    })}%`;
  }
}

export default Presenter;
