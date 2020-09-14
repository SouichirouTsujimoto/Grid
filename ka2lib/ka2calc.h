#define k_map(a, b)({ \
  std::vector<int> _result = a;\
  std::transform(a.begin(), a.end(), _result.begin(), [](decltype(a[0]) i) {\
    return b(i);\
  });\
  _result; \
  });

auto k_add = [](int a) {
  return [a](int b) { return a + b; };
};

auto k_sub = [](int a) {
  return [a](int b) {return a - b;};
};

auto k_mul = [](int a) {
  return [a](int b) {return a * b;};
};

auto k_div = [](int a) {
  return [a](int b) {return a / b;};
};

auto k_lt = [](int a) {
  return [a](int b) {return a < b;};
};

auto k_gt = [](int a) {
  return [a](int b) {return a > b;};
};

auto k_le = [](int a) {
  return [a](int b) {return a <= b;};
};

auto k_ge = [](int a) {
  return [a](int b) {return a >= b;};
};

auto k_eq = [](int a) {
  return [a](int b) {return a == b;};
};

auto k_ne = [](int a) {
  return [a](int b) {return a != b;};
};

auto k_assign = [](int *a) {
  return [a](int b) {
    *a = b;
    return b;
  };

};
